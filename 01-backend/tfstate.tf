resource "aws_s3_bucket" "tfstate" {
  bucket = var.tfstate_bucket

  tags = {
    Owner         = var.prefix
    Environment   = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate-nonpub" {
  bucket = aws_s3_bucket.tfstate.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "tfstate-versioning" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "tfstate-acl" {
  bucket = aws_s3_bucket.tfstate.id
  acl    = "private"
}

resource "aws_kms_key" "tfstate-key" {
  deletion_window_in_days = 15
  multi_region          = true
  tags = {
    Owner         = var.prefix
    Environment   = "Dev"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate-kms-conf" {
  bucket = aws_s3_bucket.tfstate.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.tfstate-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
