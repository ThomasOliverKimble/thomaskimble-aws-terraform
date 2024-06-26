# Secrets manager for GitHub access
data "aws_secretsmanager_secret" "secret" {
  name = "ThomasOliverKimble-github-aws-access-token"
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

  # Setup redirect from https://example.com to https://www.example.com
  custom_rule {
    source = "https://${var.hosted_zone}"
    status = "302"
    target = "https://www.${var.hosted_zone}"
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


# Domain association
resource "aws_amplify_domain_association" "thomaskimble" {
  app_id      = aws_amplify_app.thomaskimble_frontend.id
  domain_name = var.hosted_zone

  wait_for_verification = false

  # https://example.com
  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = ""
  }

  # https://www.example.com
  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = "www"
  }

  # https://dev.example.com
  sub_domain {
    branch_name = aws_amplify_branch.dev.branch_name
    prefix      = "dev"
  }
}
