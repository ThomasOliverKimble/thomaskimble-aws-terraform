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

  environment_variables = {
    "_CUSTOM_IMAGE" = "amplify:al2"
  }

  # Redirects for Single Page Web Apps (SPA)
  # https://docs.aws.amazon.com/amplify/latest/userguide/redirects.html#redirects-for-single-page-web-apps-spa
  custom_rule {
    source = "</^[^.]+$|\\.(?!(css|gif|ico|jpg|js|png|txt|svg|woff|ttf|map|json)$)([^.]+$)/>"
    status = "200"
    target = "/index.html"
  }

  # Setup redirect from https://thomaskimble.com to https://www.thomaskimble.com
  custom_rule {
    source = "https://thomaskimble.com"
    status = "302"
    target = "https://www.thomaskimble.com"
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

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.thomaskimble_frontend.id
  branch_name = "main"

  framework = "React"
  stage     = "PRODUCTION"
}

resource "aws_amplify_branch" "dev" {
  app_id      = aws_amplify_app.thomaskimble_frontend.id
  branch_name = "dev"

  framework = "React"
  stage     = "DEVELOPMENT"
}

resource "aws_amplify_domain_association" "thomaskimble" {
  app_id      = aws_amplify_app.thomaskimble_frontend.id
  domain_name = "thomaskimble.com"

  wait_for_verification = false

  # https://thomaskimble.com
  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = ""
  }

  # https://www.thomaskimble.com
  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = "www"
  }

  # https://dev.thomaskimble.com
  sub_domain {
    branch_name = aws_amplify_branch.dev.branch_name
    prefix      = "dev"
  }
}
