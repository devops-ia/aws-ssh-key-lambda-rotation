# S3 resource
resource "aws_s3_bucket" "ssh_rotate" {

  bucket        = "${lower(local.global_name)}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = merge(var.tags)
}

resource "aws_s3_bucket_public_access_block" "bucket_versioning" {
  bucket                  = aws_s3_bucket.ssh_rotate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_versioning" "bucket_versioning" {

  bucket = aws_s3_bucket.ssh_rotate.id
  versioning_configuration {
    status = "Suspended"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {

  bucket = aws_s3_bucket.ssh_rotate.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {

  bucket = aws_s3_bucket.ssh_rotate.id
  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "scripts" {
  for_each = fileset(path.module, "files/*.sh")

  bucket = aws_s3_bucket.ssh_rotate.id
  key    = replace("${each.value}", "files", "tools")
  source = each.value

  etag = filemd5("${each.value}")
}

resource "aws_s3_object" "libs" {
  bucket = aws_s3_bucket.ssh_rotate.id
  key    = "dependencies/libs.zip"
  source = "libs.zip"

  depends_on = [
    null_resource.build_lambda_layers
  ]

  lifecycle {
    replace_triggered_by = [
      null_resource.build_lambda_layers
    ]
  }
}
