terraform {
  required_providers {
    qovery = {
      source = "qovery/qovery"
    }
  }
}

provider "qovery" {
  token = var.qovery_access_token
}

resource "qovery_aws_credentials" "my_aws_creds_2" {
  organization_id   = var.qovery_organization_id
  name              = "My AWS Creds"
  access_key_id     = var.aws_access_key_id
  secret_access_key = var.aws_secret_access_key
}

resource "qovery_cluster" "my_cluster" {
  organization_id   = var.qovery_organization_id
  credentials_id    = qovery_aws_credentials.my_aws_creds_2.id
  name              = "Demo cluster"
  description       = "Terraform demo cluster"
  cloud_provider    = "AWS"
  region            = "us-east-2"
  instance_type     = "t3a.medium"
  min_running_nodes = 3
  max_running_nodes = 4
}

resource "qovery_project" "my_project" {
  organization_id = var.qovery_organization_id
  name            = "URL Shortener"
}

resource "qovery_environment" "production" {
  project_id = qovery_project.my_project.id
  name       = "production"
  mode       = "PRODUCTION"
  cluster_id = qovery_cluster.my_cluster.id
}

resource "qovery_application" "backend" {
  environment_id = qovery_environment.production.id
  name           = "backend"
  cpu            = 500
  memory         = 256
  git_repository = {
    url       = "https://github.com/evoxmusic/ShortMe-URL-Shortener.git"
    branch    = "main"
    root_path = "/"
  }
  build_mode            = "BUILDPACKS"
  buildpack_language    = "PYTHON"
  min_running_instances = 1
  max_running_instances = 1
  ports = [
    {
      internal_port       = 3333
      external_port       = 443
      protocol            = "HTTP"
      publicly_accessible = true
      is_default          = true
    }
  ]
  environment_variables = [
    {
      key   = "PORT"
      value = "3333"
    },
    {
      key   = "DEBUG"
      value = "false"
    }
  ]
  healthchecks = {
    readiness_probe = {
      type = {
        http = {
          scheme = "HTTP"
          port   = 3333
          path   = "/"
        }
      }
      initial_delay_seconds = 30
      period_seconds        = 10
      timeout_seconds       = 10
      success_threshold     = 1
      failure_threshold     = 3
    }
    liveness_probe = {
      type = {
        http = {
          scheme = "HTTP"
          port   = 3333
          path   = "/"
        }
      }
      initial_delay_seconds = 30
      period_seconds        = 10
      timeout_seconds       = 10
      success_threshold     = 1
      failure_threshold     = 3
    }
  }
}
