#! /usr/bin/env python

from Crypto.PublicKey import RSA
import boto3
import logging
import datetime, sys, os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def checks_resources(action, s3, s3_resource, bucket, prefix, private_key_name, public_key_name):
    '''Check resources
    
    This function performs various checks:

    1. It checks for the existence of the S3 Bucket that stores the key pair.
    2. Checks the value of a key of the event that invoked the lambda. 
        2.1. If the value contains DEPLOY, it will check if the prefix exists in the bucket, 
        if it does, it exits the function, if not, it invokes the create_key_pairs function.

        2.2. If the value contains ROTATE, it shall check if the prefix exists, if it does, 
        it invokes the rotate_objets function, otherwise it invokes the create_key_pairs function.
    '''
    try:
        # Bucket Checks
        r = s3.head_bucket(Bucket=bucket)
        logger.info(f'The AWS S3 Bucket: {bucket} exists')

        prefixes = s3.list_objects(Bucket=bucket, Prefix=prefix, Delimiter='/', MaxKeys=1)

        # Action Value and Prefix Checks
        if "DEPLOY" in action:
            if 'CommonPrefixes' in prefixes:
                logger.info(f'The {prefix}/ prefix exists on s3://{bucket}')
            else:
                logger.info(f'The {prefix} prefix does not exists on s3://{bucket}')
                create_key_pairs(s3, bucket, prefix, private_key_name, public_key_name)

        elif "ROTATE" in action:
            if 'CommonPrefixes' in prefixes:
                logger.info(f'The {prefix}/ prefix exists on s3://{bucket}')
                rotate_objects(s3, s3_resource, bucket, prefix, private_key_name, public_key_name)
            else:
                logger.info(f'The {prefix} prefix does not exists on s3://{bucket}')
                create_key_pairs(s3, bucket, prefix, private_key_name, public_key_name)
        else:
            logger.info(f'The event received for the invocation of this lambda does not contain any expected body')

    except Exception as e:
        logger.error(e)
        sys.exit(1)


def rotate_objects(s3, s3_resource, bucket, prefix, private_key_name, public_key_name):
    '''Objects rotation.

    This function obtains the current date with format YYYYY-MM-DD, and checks if this prefix 
    exists in the S3 Bucket, if it exists it indicates that this process has been launched at 
    least once during the same day, therefore rotation with a minimum of 24h is not supported.

    If the prefix does not exist in the S3 Bucket, it indicates that the rotation can be 
    performed by executing the following steps:

    1. The function iterates over all the objects stored in the defined prefix "current" 
       and copies them to another directory with format YYYYY-MM-DD of the same S3 Bucket.

    2. Deletes the objects it has just copied.

    3. As a last operation of this function it invokes the function that allows to manage new keys.
    '''
    try:
        # Obtain today isoformat
        # YYYY-MM-DD
        today = datetime.date.today()
        todaystr = today.isoformat()

        # Check if date prefix exists on bucket
        search_date_prefix = s3.list_objects(Bucket=bucket, Prefix=todaystr, Delimiter='/', MaxKeys=1)

        if 'CommonPrefixes' in search_date_prefix:
            logger.info(f'The {todaystr} prefix already exists. Keys can only be rotated every 24h')
            sys.exit(0)

        # Query for get all objects
        s3_objects = s3.list_objects(Bucket=bucket, Prefix=prefix)

        # Iterate for all objects
        for object in s3_objects.get('Contents'):
        
            # Replace string current
            ## obj example: /object.extension
            obj = object.get('Key').replace(prefix, "")
        
            # Move objects
            s3_resource.Object(bucket,todaystr + obj).copy_from(CopySource=str(f'{bucket}/{prefix}{obj}'))
            logger.info(f'Move file s3://{bucket}/{prefix}{obj} to s3://{bucket}/{todaystr}{obj}')
        
            # Delete old objects
            s3_resource.Object(bucket, prefix + obj).delete()
            logger.info(f'Delete file s3://{bucket}/{prefix}{obj}')

        # Invoke Manage Key Pairs function
        create_key_pairs(s3, bucket, prefix, private_key_name, public_key_name)

    except Exception as e:
        logger.error(f'Failed rotate_objects function {e}')
        sys.exit(1)


def create_key_pairs(s3, bucket, prefix, private_key_name, public_key_name):
    '''Key pair management.
    
    It allows the creation of key pairs and the uploading of these new keys to the "current" prefix of 
    the S3 Bucket. These will be the new keys that must be shared with users who need to access the 
    machines as privileged users.

    '''
    try:
        key = RSA.generate(2048)
        with open(f"/tmp/{private_key_name}", 'wb') as content_file:
            content_file.write(key.exportKey('PEM'))
        logger.info('Create Key successfully')

        pubkey = key.publickey()
        with open(f"/tmp/{public_key_name}", 'wb') as content_file:
            content_file.write(pubkey.exportKey('OpenSSH'))
        logger.info('Create Private Key successfully')

    except Exception as e:
        logger.error(f'Error when Keys created {e}')
        sys.exit(1)

    try:
        s3.upload_file(str(f'/tmp/{private_key_name}'), bucket, str(f'{prefix}/{private_key_name}'))
        logger.info(f'Upload object /tmp/{private_key_name} to s3://{bucket}/{prefix}/{private_key_name}')

        s3.upload_file(str(f'/tmp/{public_key_name}'), bucket, str(f'{prefix}/{public_key_name}'))
        logger.info(f'Upload object /tmp/{public_key_name} to s3://{bucket}/{prefix}/{public_key_name}')

    except Exception as e:
        logger.error(f'Failed when upload Keys to AWS S3 {bucket} {e}')
        sys.exit(1)


def ssm_run_command(ssm, lgroup, tag_key, bucket, prefix, public_key_name):
    '''AWS System Manager Run Command.

    Allows to send to the EC2 instances of the tag containing the indicated tag-key and tag-value, a 
    command for the replacement of existing ssh keys by the ones declared in the "current" prefix of the 
    S3 Bucket in the authorized_keys file.

    Finally, this process will wait until the job gets a "Success" status.

    Logs pertaining to the execution of the AWS System Manager Run Command process will be stored in AWS 
    Cloudwatch Logs under the Log Group /aws/ssm/ssh-rotate-<project>.

    '''
    # Run command
    try:
        o = ssm.send_command(
            Targets=[
                {
                    'Key': 'tag-key',
                    'Values': [
                        str(f'{tag_key}')
                    ]
                }
            ],
            DocumentName='AWS-RunShellScript',
            DocumentVersion='$DEFAULT',
            TimeoutSeconds=120,
            Comment='Allows ssh key rotation on instances containing the tag to be declared',
            Parameters={
                'commands': [
                    # Download ssh key
                    str(f'aws s3 cp s3://{bucket}/{prefix}/{public_key_name} /tmp/authorized_keys'),
                    # Rotate authorized_key file
                    'cat /tmp/authorized_keys > /home/ec2-user/.ssh/authorized_key',

                ]
            },
            CloudWatchOutputConfig={
                'CloudWatchLogGroupName': str(lgroup),
                'CloudWatchOutputEnabled': True
            }
        )

        logger.info(f'Exec AWS Run CommandId: {o["Command"]["CommandId"]}')
        
        # Get CommandId
        command_id = o['Command']['CommandId']
        st = ssm.list_commands(
            CommandId=command_id
        )
        
        # Wait for the job status to be "Success"
        while st["Commands"][0]["Status"] != "Success":
            logger.info(f'AWS Run CommandId: {st["Commands"][0]["CommandId"]} is {st["Commands"][0]["Status"]} ...')
            
            st = ssm.list_commands(
                CommandId=command_id
            )

        logger.info(f'AWS Run CommandId: {st["Commands"][0]["CommandId"]} is {st["Commands"][0]["Status"]}')

    except Exception as e:
        logger.error(f'Failed AWS Run Command {e}')
        sys.exit(1)


def main(event, context=None):
    '''Main

    The lambda will be invoked through different events. 
    Through AWS SQS or through Test Event in the lambda itself, both events have a key-value 
    under event['Records'][0]['body'], which can be DEPLOY or ROTATE.

    Example:
    ```json
    {
        "Records": [
            {
                "messageId": "null",
                "receiptHandle": "null",
                "body": "{\n  \"FUNCTION\" : \"DEPLOY\"\n}",
                "md5OfBody": "null",
                "eventSource": "null",
                "eventSourceARN": "null",
                "awsRegion": "null"
            }
        ]
    }
    ```

    '''
    # environment config
    bucket = os.getenv('AWS_S3_BUCKET')
    lgroup = os.getenv('AWS_LOG_GROUP_NAME')
    prefix = os.getenv('AWS_S3_PREFIX', 'current')
    private_key_name = os.getenv('PRIVATE_KEY_NAME', 'key.pem')
    public_key_name = os.getenv('PUBLIC_KEY_NAME', 'key.pub')
    tag_key = os.getenv('TAG_KEY')
    action = event['Records'][0]['body']

    # Clients
    s3 = boto3.client('s3')
    s3_resource = boto3.resource('s3')
    ssm = boto3.client('ssm')

    # Invoke functions
    checks_resources(action, s3, s3_resource, bucket, prefix, private_key_name, public_key_name)
    ssm_run_command(ssm, lgroup, tag_key, bucket, prefix, public_key_name)
    

if __name__ == "__main__":
  main()