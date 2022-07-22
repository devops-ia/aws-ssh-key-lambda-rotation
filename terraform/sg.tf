# SG
module "sg_sample_rotate" {
  count  = var.testing_enabled ? 1 : 0
  source = "terraform-aws-modules/security-group/aws"

  name            = "ec2_sample_rotate-${lower(local.global_name)}"
  use_name_prefix = false
  description     = "Managed Terraform"
  vpc_id          = module.vpc[0].vpc_id

  egress_rules = ["all-all"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "My IP"
      cidr_blocks = var.my_ip
    }
  ]

  tags = merge(var.tags)
}
