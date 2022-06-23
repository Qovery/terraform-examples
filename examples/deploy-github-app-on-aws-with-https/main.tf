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

resource "qovery_aws_credentials" "my_aws_creds" {
  organization_id   = var.qovery_organization_id
  name              = "My AWS Creds"
  access_key_id     = var.aws_access_key_id
  secret_access_key = var.aws_secret_access_key
}

resource "qovery_cluster" "my_cluster" {
  organization_id   = var.qovery_organization_id
  credentials_id    = qovery_aws_credentials.my_aws_creds.id
  name              = "Demo cluster"
  description       = "Terraform demo cluster"
  cloud_provider    = "AWS"
  region            = "us-east-2"
  instance_type     = "T3A_MEDIUM"
  min_running_nodes = 3
  max_running_nodes = 4
  state             = "RUNNING"

  depends_on = [
    qovery_aws_credentials.my_aws_creds
  ]
}

resource "qovery_project" "my_project" {
  organization_id = var.qovery_organization_id
  name            = "URL Shortener"

  depends_on = [
    qovery_cluster.my_cluster
  ]
}

resource "qovery_environment" "production" {
  project_id = qovery_project.my_project.id
  name       = "production"
  mode       = "PRODUCTION"
  cluster_id = qovery_cluster.my_cluster.id

  depends_on = [
    qovery_project.my_project
  ]
}

resource "qovery_application" "backend" {
  environment_id = qovery_environment.production.id
  name           = "backend"
  cpu            = 500
  memory         = 256
  state          = "RUNNING"
  git_repository = {
    url       = "https://github.com/evoxmusic/ShortMe-URL-Shortener.git"
    branch    = "main"
    root_path = "/"
  }
  build_mode            = "BUILDPACKS"
  buildpack_language    = "PYTHON"
  min_running_instances = 1
  max_running_instances = 1
  ports                 = [
    {
      internal_port       = 3333
      external_port       = 443
      protocol            = "HTTP"
      publicly_accessible = true
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

  depends_on = [
    qovery_environment.production,
  ]
}
