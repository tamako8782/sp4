variable "static_bucket_name" {
  type = string
}

resource "aws_s3_bucket" "static_bucket" {
  bucket = var.static_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "static_bucket_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.static_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_s3_bucket_ownership_controls" "static_bucket_ownership" {
  bucket = aws_s3_bucket.static_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "static_bucket_public_access" {
  bucket = aws_s3_bucket.static_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_policy" "static_bucket_policy" {
    bucket = aws_s3_bucket.static_bucket.id
    policy = data.aws_iam_policy_document.static_bucket_policy.json
}

data "aws_iam_policy_document" "static_bucket_policy" {
    statement {
        sid = "Allow CloudFront"
        effect = "Allow"
        actions = ["s3:GetObject"]
        resources = ["${aws_s3_bucket.static_bucket.arn}/*"]
        principals {
            type = "Service"
            identifiers = ["cloudfront.amazonaws.com"]
        }
        condition {
            test = "StringEquals"
            variable = "AWS:SourceArn"
            values = [aws_cloudfront_distribution.static_bucket_distribution.arn]
        }
    }
}
