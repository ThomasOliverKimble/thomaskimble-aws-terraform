locals {
  structure = yamldecode(file("${path.module}/file_structure.yaml"))

  # Extract terminal paths with a fixed depth of 4
  paths = toset(flatten([
    for key1, value1 in local.structure : [
      for key2, value2 in value1 : [
        for key3, value3 in value2 : [
          for key4, value4 in value3 :
          "${key1}/${key2}/${key3}/${key4}"
          if can(list(value3)) && length(value3) > 0
        ]
        if can(list(value2)) && length(value2) > 0
      ]
      if can(list(value1)) && length(value1) > 0
    ]
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
  for_each = local.paths
  bucket   = aws_s3_bucket.thomaskimble_bucket.id
  key      = each.value
}
