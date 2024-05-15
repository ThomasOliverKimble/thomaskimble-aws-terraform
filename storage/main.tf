resource "aws_s3_bucket" "thomaskimble_bucket" {
  bucket = "thomaskimble-storage"
}

resource "aws_s3_bucket_policy" "thomaskimble_bucket_policy" {
  bucket = aws_s3_bucket.thomaskimble_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = "*"
        Action    = ["s3:GetObject", ]
        Effect    = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.thomaskimble_bucket}",
          "arn:aws:s3:::${aws_s3_bucket.thomaskimble_bucket}/*"
        ]
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.thomaskimble_bucket_public_access_block]
}

resource "aws_s3_bucket_acl" "thomaskimble_bucket_acl" {
  bucket     = aws_s3_bucket.thomaskimble_bucket.id
  acl        = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.thomaskimble_bucket_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "thomaskimble_bucket_acl_ownership" {
  bucket = aws_s3_bucket.thomaskimble_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.thomaskimble_bucket_public_access_block]
}

resource "aws_s3_bucket_public_access_block" "thomaskimble_bucket_public_access_block" {
  bucket = aws_s3_bucket.thomaskimble_bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_cors_configuration" "thomaskimble_bucket_cors_configuration" {
  bucket = aws_s3_bucket.thomaskimble_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
