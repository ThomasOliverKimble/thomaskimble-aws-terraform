resource "aws_s3_bucket" "thomaskimble_storage" {
  bucket = "thomaskimble-storage"
}

resource "aws_s3_bucket_acl" "thomaskimble_storage_acl" {
  bucket = aws_s3_bucket.thomaskimble_storage.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "thomaskimble_bucket_policy" {
  bucket = aws_s3_bucket.thomaskimble_storage.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.thomaskimble_storage.arn}/*"
      }
    ]
  })
}
