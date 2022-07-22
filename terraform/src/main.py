#! /usr/bin/env python

from Crypto.PublicKey import RSA
from botocore.exceptions import ClientError
import boto3
import logging
import time
import datetime, sys, os

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def checks_resources(event_source, s3, s3_resource, env_vars):
    '''Check resources
    
    This function performs various checks:

    1. it checks for the existence of the S3 Bucket that stores the key pair.
    2. Checks the Event Source that invoked the lambda. 
        
        2.1. If the value is the same as the AWS SQS `Deploy` ARN.
            2.1.1. If the prefix exists, terminate the function and continue with the program. 
            2.1.2. If it does not exist, invoke the manage_key_pairs function.

        2.2. If the value is the same as the AWS SQS `Rotate` ARN.
            2.2.1. If the prefix exists, call the rotate_objects function, 
            2.2.2. If it does not exist, invoke the manage_key_pairs function.
    '''
    
    logger.info(f'Init check resources function for instances resource.')
    
    # Bucket Check
    try:
        r = s3.head_bucket(Bucket=env_vars.get('bucket'))
        logger.info(f'The AWS S3 Bucket: {env_vars.get("bucket")} exists.')

    except Exception as e:
        logger.error(f'The AWS S3 Bucket: {env_vars.get("bucket")} does NOT exists. {e}.')
        sys.exit(1)

    try:
        # Conditional EventSource and Prefix Checks
        prefixes = s3.list_objects(Bucket=env_vars.get('bucket'), Prefix='instances/'+env_vars.get('prefix'), Delimiter='/', MaxKeys=1)

        if event_source == env_vars.get('arn_sqs_deploy'):
            if 'CommonPrefixes' in prefixes:
                logger.info(f'The instances/{env_vars.get("prefix")} prefix exists on s3://{env_vars.get("bucket")}.')
            else:
                logger.info(f'The instances/{env_vars.get("prefix")} prefix does not exists on s3://{env_vars.get("bucket")}.')
                manage_key_pairs(s3, env_vars)

        elif event_source == env_vars.get('arn_sqs_rotate'):
            if 'CommonPrefixes' in prefixes:
                logger.info(f'The instances/{env_vars.get("prefix")} prefix exists on s3://{env_vars.get("bucket")}.')
                rotate_objects(s3, s3_resource,  env_vars)
            else:
                logger.info(f'The instances/{env_vars.get("prefix")} prefix does not exists on s3://{env_vars.get("bucket")}.')
                manage_key_pairs(s3, env_vars)
        else:
            logger.info(f'The event received for the invocation of this lambda does not contain any expected event source.')

    except Exception as e:
        logger.error(f'Error when evaluating the event source or trying to obtain a list of bucket objects {e}.')
        sys.exit(1)


def rotate_objects(s3, s3_resource, env_vars):
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

    logger.info(f'Init rotate objects function for instances resource.')
    
    try:
        # Obtain today isoformat
        ## YYYY-MM-DD
        today = datetime.date.today()
        todaystr = today.isoformat()

        # Check if date prefix exists on bucket
        search_date_prefix = s3.list_objects(Bucket=env_vars.get("bucket"), Prefix='instances/'+todaystr, Delimiter='/', MaxKeys=1)

        if 'CommonPrefixes' in search_date_prefix:
            logger.info(f'The instances/{todaystr} prefix already exists. Keys can only be rotated every 24h.')
            sys.exit(0)

        # Query for get all objects
        s3_objects = s3.list_objects(Bucket=env_vars.get("bucket"), Prefix='instances/'+env_vars.get("prefix"))

        # Iterate for all objects
        for object in s3_objects.get('Contents'):
        
            # Replace string
            ## obj example: /object.extension
            obj = object.get('Key').replace('instances/'+env_vars.get("prefix"), "")
        
            # Move objects
            s3_resource.Object(env_vars.get("bucket"), 'instances/' + todaystr + obj).copy_from(CopySource=str(f'{env_vars.get("bucket")}/instances/{env_vars.get("prefix")}{obj}'))
            logger.info(f'Move file s3://{env_vars.get("bucket")}/instances/{env_vars.get("prefix")}{obj} to s3://{env_vars.get("bucket")}/instances/{todaystr}{obj}.')
        
            # Delete old objects
            s3_resource.Object(env_vars.get("bucket"), 'instances/' + env_vars.get("prefix") + obj).delete()
            logger.info(f'Delete file s3://{env_vars.get("bucket")}/instances/{env_vars.get("prefix")}{obj}.')

        # Invoke Manage Key Pairs function
        manage_key_pairs(s3, env_vars)

    except Exception as e:
        logger.error(f'Error in rotate_objects function {e}')
        sys.exit(1)


def manage_key_pairs(s3, env_vars):
    '''Manage Key Pairs.
    
    It allows the creation of key pairs and the uploading of these new keys to the "current" prefix of 
    the S3 Bucket. These will be the new keys that must be shared with users who need to access the 
    machines as privileged users.

    '''

    logger.info(f'Init Manage Key Pairs function for instances resource.')

    try:
        key = RSA.generate(2048)
        with open(f"/tmp/key.pem", 'wb') as content_file:
            content_file.write(key.exportKey('PEM'))
        logger.info('Create Key successfully.')

        pubkey = key.publickey()
        with open(f"/tmp/key.pub", 'wb') as content_file:
            content_file.write(pubkey.exportKey('OpenSSH'))
        logger.info('Create Private Key successfully.')

    except Exception as e:
        logger.error(f'Error when Keys created {e}.')
        sys.exit(1)

    try:
        s3.upload_file(str(f'/tmp/key.pem'), env_vars.get("bucket"), str(f'instances/{env_vars.get("prefix")}/key.pem'))
        logger.info(f'Upload object /tmp/key.pem to s3://{env_vars.get("bucket")}/instances/{env_vars.get("prefix")}/key.pem.')

        s3.upload_file(str(f'/tmp/key.pub'), env_vars.get("bucket"), str(f'instances/{env_vars.get("prefix")}/key.pub'))
        logger.info(f'Upload object /tmp/key.pub to s3://{env_vars.get("bucket")}/instances/{env_vars.get("prefix")}/key.pub.')

    except Exception as e:
        logger.error(f'Error when upload Keys to AWS S3 {env_vars.get("bucket")} {e}.')
        sys.exit(1)


def ssm_run_command(ssm, env_vars):
    '''AWS System Manager Run Command.

    It allows to send to the EC2 instances containing the indicated key-tag and value-tag, bash script commands.

    There are two processes:

    1. Once the above functions have been executed the function that allows to invoke the AWS SSM Run Command service. 
    This service allows to send the command that will replace the existing key of the tagged instances with those declared 
    in the current prefix of the configured AWS S3 Bucket. Previously I will check the primary user according to the type 
    of image used in the instance.

    2. In this second step, configure SSH with a configuration file and the SSH key for the user 
    jailed `admin` on the tagged instances as rotate=<tag_rotate>.

    Logs corresponding to the execution of the AWS System Manager Run Command process will be stored in AWS 
    Cloudwatch Logs under the /aws/ssm/ssh-rotate-<environment> log group.

    '''

    logger.info(f'Init SSM Run Command function for instances resource.')

    # Run Command to deploy/rotate ssh keys
    try:
        o = ssm.send_command(
            Targets=[
                {
                    'Key': 'tag:environment',
                    'Values': [
                        str(env_vars.get('tag_value_environment')),
                    ]
                },
                {
                    'Key': 'tag:rotate',
                    'Values': [
                        str(f'{env_vars.get("tag_value_rotate")}'),
                    ]
                }
            ],
            DocumentName='AWS-RunShellScript',
            DocumentVersion='$DEFAULT',
            TimeoutSeconds=120,
            Comment=str(f'SSH rotation on the tagged instances with rotate={env_vars.get("tag_value_rotate")}.'),
            Parameters={
                'commands': [
                    str(f'aws s3 cp s3://{env_vars.get("bucket")}/tools/instances.sh /tmp/instances.sh'),
                    'chmod +x /tmp/instances.sh',
                    str(f'/tmp/instances.sh {env_vars.get("bucket")} {env_vars.get("prefix")} {env_vars.get("script_loop")} {env_vars.get("script_sleep")}'),
                    'rm -f /tmp/instances.sh',
                ]
            },
            ServiceRoleArn=str(env_vars.get('sns_role_arn')),
            NotificationConfig={
                'NotificationArn': str(env_vars.get('sns_notification_arn')),
                'NotificationEvents': [
                    'TimedOut',
                    'Cancelled',
                    'Failed',
                ],
                'NotificationType': 'Command'
            },
            CloudWatchOutputConfig={
                'CloudWatchLogGroupName': str(env_vars.get('lgroup')),
                'CloudWatchOutputEnabled': True
            }
        )

        logger.info(f'Exec AWS Run CommandId: {o["Command"]["CommandId"]}.')

    except Exception as e:
        logger.error(f'Error on AWS Run Command function {e}.')
        sys.exit(1)

def send_email(sns, env_vars):
    '''Notification Email

    Function notifying key rotation

    '''

    logger.info(f'Init send email function.')

    # Send email
    try:
        r = sns.publish(
            TopicArn=str(f'{env_vars.get("sns_rotate_notification_arn")}'),
            Message=str(f'''                    
                This message has been generated by the SSH key rotation AWS Lambda of the {env_vars.get("tag_value_environment").upper()} account.
                
                The keys can be found at the following location: s3://{env_vars.get("bucket")}/* 
                
                Regards.''').replace('                ', ''),
        )

    except ClientError as e:
        print(f'Error when trying to send the email. {e.response["Error"]["Message"]}.')
        sys.exit(1)
    else:
        logger.info(f'Message publish on AWS SNS.')


def main(event, context=None):
    '''Main

     The lambda is invoked by AWS SQS queues. 
    It gets the event source through event['Records'][0]['eventSourceARN'].

    For each resource declared in the `resources` variable it executes the checks_resources and ssm_run_command 
    functions.
    
    It is also possible to impersonate an AWS SQS queue, configuring Test Events in the Lambda, useful for 
    debugging.

    Example Deploy:
    ```json
    {
       "Records":[
          {
             "eventSourceARN":"<arn-sqs-deploy>"
          }
       ]
    }
    ```

    Example Rotate:
    ```json
    {
       "Records":[
          {
             "eventSourceARN":"<arn-sqs-rotate>"
          }
       ]
    }
    ```
    '''

    # Environment Variables
    env_vars = {
        'arn_sqs_rotate'               : os.getenv('ARN_SQS_ROTATE'),
        'arn_sqs_deploy'               : os.getenv('ARN_SQS_DEPLOY'),
        'lgroup'                       : os.getenv('AWS_LOG_GROUP_NAME'),
        'bucket'                       : os.getenv('AWS_S3_BUCKET'),
        'prefix'                       : os.getenv('AWS_S3_PREFIX'),
        'script_loop'                  : os.getenv('SCRIPT_LOOP'),
        'script_sleep'                 : os.getenv('SCRIPT_SLEEP'),
        'sns_rotate_notification_arn'  : os.getenv('SNS_ROTATE_NOTIFICATION_ARN'),
        'sns_notification_arn'         : os.getenv('SNS_NOTIFICATION_ARN'),
        'sns_role_arn'                 : os.getenv('SNS_ROLE_ARN'),
        'tag_value_environment'        : os.getenv('TAG_VALUE_ENVIRONMENT'),
        'tag_value_rotate'             : os.getenv('TAG_VALUE_ROTATE'),
    }
    
    # Get EventSource
    event_source = event['Records'][0]['eventSourceARN']

    # Clients
    s3 = boto3.client('s3')
    s3_resource = boto3.resource('s3')
    ssm = boto3.client('ssm')
    sns = boto3.client('sns')

    logger.info(f'The Lambda function has been invoked from the source: {event_source}.')

    # Invoke functions
    checks_resources(event_source, s3, s3_resource, env_vars)
    ssm_run_command(ssm, env_vars)
    
    # Invoke email function
    if event_source == env_vars.get('arn_sqs_deploy'):
        logger.info(f'Source received through AWS SQS {event_source} queue does not trigger email notification.')
    elif event_source == env_vars.get('arn_sqs_rotate'):
        logger.info(f'Source received via SQS {event_source} queue triggers notification via email.')
        send_email(sns, env_vars)
    else:
        logger.info(f'The event received for the invocation of email function does not contain any expected event source.')

if __name__ == "__main__":
  main()