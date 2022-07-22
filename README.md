# aws-ssh-key-lambda-rotation

AWS does not allow you to modify the SSH key of EC2 instances, the option they suggest is to recreate the instance with a new key.

This repository provides an automated alternative for SSH key rotation with AWS services.

It allows the generation of Key Pairs and rotation over S3 Buckets, setting the new keys on the machines matching the defined TAG. In addition, it allows key modification when new EC2 machines are provisioned.

## Diagram

![alt text](img/diagram.png "Title")

## How to use it

* Execute the script that allows to create the s3 where the TFSTATE will be stored. [./terraform/scripts/create_backend_config.sh](./terraform/scripts/create_backend_config.sh).
`./terraform/scripts/create_backend_config.sh example-bucket eu-west-1`

* Modify the bucket config and the region in the [terraform_config.tf](terraform/terraform_config.tf) file.
* Check [terraform.tfvars](terraform/terraform.tvars) file and include your Public IP.

* Deploy code:
`terraform -chdir=terraform init`
`terraform -chdir=terraform apply`

* Test ssh instance:
```sh
ssh -i terraform/rsa.pem ec2-user@<public-ip>

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
12 package(s) needed for security, out of 22 available
Run "sudo yum update" to apply all updates.
$ >  
```

* You can run the AWS Kambda code by creating two test events:
Rotate:
```json
{
       "Records":[
          {
             "eventSourceARN":"<arn-sqs-rotate>"
          }
       ]
    }
```

Deploy:
```json
{
       "Records":[
          {
             "eventSourceARN":"<arn-sqs-deploy>"
          }
       ]
    }
```

* Once executed, download the new keys
`./terraform/scripts/download_keys.sh <rotate-bucket-name>`

* Check ssh instance:
```sh
ssh -i key_pairs/instance_key.pem ec2-user@<public-ip>
Last login: Fri Jul 22 11:39:22 2022 from XX.XX.XX.XX

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
12 package(s) needed for security, out of 22 available
Run "sudo yum update" to apply all updates.
$ >
```