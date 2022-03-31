## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.15.5 |
| aws | ~> 4.2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 4.2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| lambda\_handler | Lambda handler init | `string` | `"main.main"` | no |
| lambda\_layer\_package | Lambda layer package | `string` | `"crypto"` | no |
| lambda\_layer\_runtime | List of layer runtime compatible | `list(any)` | <pre>[<br>  "python3.8",<br>  "python3.9"<br>]</pre> | no |
| lambda\_private\_key\_name | Private Key Name | `string` | `"tag.pem"` | no |
| lambda\_public\_key\_name | Public Key Name | `string` | `"tag.pub"` | no |
| lambda\_runtime | Lambda program runtime | `string` | `"python3.8"` | no |
| lambda\_s3\_prefix | Bucket S3 Prefix | `string` | `"current"` | no |
| lambda\_tag\_key | Tag Key | `string` | `"provisioning"` | no |
| lambda\_timeout | Lambda timeout | `number` | `60` | no |
| loggroup\_ssh\_rotate\_retention | AWS Cloudwatch Logs Retention for SSM Run Command | `number` | `365` | no |
| sqs\_delay\_seconds | The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes) | `number` | `60` | no |
| sqs\_visibility\_timeout\_seconds | The visibility timeout for the queue. An integer from 0 to 43200 (12 hours) | `number` | `180` | no |
| tags | Service tags | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| eventbridge\_aws\_cloudwatch\_event\_rule | Trigger to launch ssh-rotate Lambda |
| eventbridge\_aws\_cloudwatch\_event\_target | Target to sent Events Trigger |
| lambda\_cw\_lgroup\_ssh\_rotate\_name | AWS Cloudwatch Log Group Name |
| lambda\_function\_ssh\_rotate\_name | AWS Lambda function name for ssh rotate |
| lambda\_policy\_ssh\_rotate\_name | AWS IAM Policy name for ssh rotate |
| lambda\_role\_ssh\_rotate\_name | AWS IAM Role name for ssh rotate |
| loggroup\_ssh\_rotate\_name | AWS Cloudwatch Log Group name for System Manager Run Command ssh rotate |
| s3\_ssh\_rotate\_name | AWS S3 name |
| sqs\_ssh\_rotate\_name | AWS SQS name |