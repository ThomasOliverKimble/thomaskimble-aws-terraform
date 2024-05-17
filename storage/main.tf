# Create local variables for paths
locals {
  structure = yamldecode(file("${path.module}/file_structure.yaml"))

  paths = toset(flatten([
    for k, v in local.structure : [for subk, subv in v : "${k}/${subk}/"] if can(v)
  ]))
}


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
        Action    = ["s3:GetObject"]
        Effect    = "Allow"
        Resource  = ["${aws_s3_bucket.thomaskimble_bucket.arn}/*"]
      },
    ]
  })
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
}

# Create S3 objects for each path
resource "aws_s3_object" "create_paths" {
  for_each = toset(local.paths)
  bucket   = aws_s3_bucket.thomaskimble_bucket.id
  key      = each.value
}
