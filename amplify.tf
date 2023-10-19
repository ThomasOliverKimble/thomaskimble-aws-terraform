data "aws_secretsmanager_secret" "secret" {
  arn = "arn:aws:secretsmanager:eu-west-1:287212251408:secret:ThomasOliverKimble-github-aws-access-token-Smhr9D"
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secret.id
}

output "secret_output" {
  value = jsondecode(nonsensitive(data.aws_secretsmanager_secret_version.current.secret_string))
}

resource "aws_amplify_app" "thomaskimble_frontend" {
  name       = "thomaskimble_frontend"
  repository = "https://github.com/ThomasOliverKimble/thomaskimble-frontend"

  # access_token = jsondecode(nonsensitive(data.aws_secretsmanager_secret_version.current.secret_string))

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
