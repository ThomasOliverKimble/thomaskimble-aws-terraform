resource "aws_dynamodb_table" "projects" {
  name         = "projects"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "N"
  }

  attribute {
    name = "path"
    type = "S"
  }

  global_secondary_index {
    name            = "path-index"
    hash_key        = "path"
    projection_type = "ALL"
  }
}
