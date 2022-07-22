# Locals
locals {
  global_name = "${var.tags["project"]}-${var.tags["environment"]}"
  deploy_name = "${lower(var.tags["project"])}-deploy-${lower(var.tags["environment"])}"
  rotate_name = "${lower(var.tags["project"])}-rotate-${lower(var.tags["environment"])}"
}
