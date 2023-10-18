resource "aws_ssm_parameter" "test_parameter" {
  name = "Test"
  type = "String"
  value = "result"
}