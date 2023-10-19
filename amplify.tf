data "aws_secretsmanager_secret" "secret" {
  arn = "arn:aws:secretsmanager:eu-west-1:287212251408:secret:ThomasOliverKimble-github-aws-access-token-Smhr9D"
}

resource "aws_amplify_app" "thomaskimble-frontend" {
  name       = "thomaskimble-frontend"
  repository = "https://github.com/ThomasOliverKimble/thomaskimble-frontend"

  access_token = data.aws_secretsmanager_secret.secret.value

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
