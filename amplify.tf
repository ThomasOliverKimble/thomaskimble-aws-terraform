# Secrets manager for GitHub access
data "aws_secretsmanager_secret" "secret" {
  arn = "arn:aws:secretsmanager:eu-west-1:287212251408:secret:ThomasOliverKimble-github-aws-access-token-Smhr9D"
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secret.id
}

# Applify setup
resource "aws_amplify_app" "thomaskimble_frontend" {
  name       = "thomaskimble-frontend"
  repository = "https://github.com/ThomasOliverKimble/thomaskimble-frontend"

  access_token = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["ThomasOliverKimble-github-aws-access-token"]

  enable_branch_auto_build    = true
  enable_branch_auto_deletion = true

  auto_branch_creation_patterns = [
    "*",
    "*/**"
  ]

  auto_branch_creation_config = {
    enable_auto_build = true
  }

  build_spec = <<-EOT
    version: 0.1
    frontend:
      phases:
        preBuild:
            commands:
              - npm ci
        build:
            commands:
              - npm run build
      artifacts:
        baseDirectory: build
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT
}
