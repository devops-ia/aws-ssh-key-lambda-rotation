# EC2 Resources
## TLS Private Key
resource "tls_private_key" "testing" {
  count     = var.testing_enabled ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

## Key pair
resource "aws_key_pair" "testing" {
  count = var.testing_enabled ? 1 : 0

  key_name   = lower(local.global_name)
  public_key = tls_private_key.testing[0].public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.testing[0].private_key_pem}' > rsa.pem"

    interpreter = ["bash", "-c"]
  }
}

## AWS EC2 Sample instance
module "ec2_sample_rotate" {
  count   = var.testing_enabled ? 1 : 0
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.0"

  name = "instance-${lower(local.global_name)}"

  ami                         = data.aws_ami.ami.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.testing[0].key_name
  monitoring                  = false
  vpc_security_group_ids      = ["${module.sg_sample_rotate[0].security_group_id}"]
  subnet_id                   = module.vpc[0].public_subnets[0]
  iam_instance_profile        = aws_iam_instance_profile.instances_profile[0].name
  associate_public_ip_address = true

  tags = merge(var.tags, var.tags_rotate)
}