########################################
# Module 4 — Storage (S3 Integration)
########################################

# Who am I? (for account ID)
data "aws_caller_identity" "current" {}

# ---- S3 Bucket ----
resource "aws_s3_bucket" "photos" {
  bucket = var.s3_bucket_name   # e.g., "employee-photo-bucket-456s"
  tags   = merge(var.tags, { Name = var.s3_bucket_name })
}

# Keep default settings: block public access
resource "aws_s3_bucket_public_access_block" "photos" {
  bucket                  = aws_s3_bucket.photos.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Optional: versioning off by default (left as default)

# Bucket policy: allow ONLY the EC2 role to access this bucket
# (Mirrors the console step where you replaced account ID and bucket name)
data "aws_iam_policy_document" "photos_policy" {
  statement {
    sid     = "AllowS3AccessFromEC2Role"
    effect  = "Allow"

    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.ec2_role.name}"
      ]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.photos.arn,
      "${aws_s3_bucket.photos.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "photos" {
  bucket = aws_s3_bucket.photos.id
  policy = data.aws_iam_policy_document.photos_policy.json

  depends_on = [aws_s3_bucket_public_access_block.photos]
}

# ---- Optional: upload a test image (e.g., employee2.jpg) ----
# Provide a local path via var.test_object_source to enable
resource "aws_s3_object" "test_image" {
  count  = var.test_object_source != "" ? 1 : 0
  bucket = aws_s3_bucket.photos.id
  key    = var.test_object_key
  source = var.test_object_source
  etag   = filemd5(var.test_object_source)
  content_type = "image/jpeg"
  tags = merge(var.tags, { Purpose = "Module4TestUpload" })
}

########################################
# Helpful outputs
########################################
output "s3_bucket_name" {
  value       = aws_s3_bucket.photos.bucket
  description = "S3 bucket name used by the app"
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.photos.arn
  description = "S3 bucket ARN"
}
