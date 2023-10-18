resource "aws_ssm_parameter" "test_parameter" {
  name = "Test"
  type = "String"
  value = "result"
}

# resource "aws_s3_bucket" "thomaskimble-test-bucket" {
#   bucket = "thomaskimble-test-bucket"
# }
