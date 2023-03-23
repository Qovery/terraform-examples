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
  instance_type     = "T3A_MEDIUM"
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

resource "qovery_application" "backend_1" {
  environment_id = qovery_environment.production.id
  name           = "backend"
  cpu            = 250
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

  deployment_stage_id = qovery_deployment_stage.first_deployment_stage.id
}

resource "qovery_application" "backend_2" {
  environment_id = qovery_environment.production.id
  name           = "backend"
  cpu            = 250
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

  deployment_stage_id = qovery_deployment_stage.second_deployment_stage.id
}

resource "qovery_application" "backend_3" {
  environment_id = qovery_environment.production.id
  name           = "backend"
  cpu            = 250
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

  deployment_stage_id = qovery_deployment_stage.third_deployment_stage.id
}

resource "qovery_deployment" "prod_deployment" {
  environment_id = qovery_environment.production.id
  desired_state  = "RUNNING"
}

resource "qovery_deployment_stage" "first_deployment_stage" {
  # Required
  environment_id = qovery_environment.production.id
  name           = "First Stage"

  # Optional
  description = "this is my first deployment stage"
}

resource "qovery_deployment_stage" "second_deployment_stage" {
  # Required
  environment_id = qovery_environment.production.id
  name           = "Second Stage"

  # Optional
  description = "this is my second deployment stage"
  move_after  = qovery_deployment_stage.first_deployment_stage.id
}

resource "qovery_deployment_stage" "third_deployment_stage" {
  # Required
  environment_id = qovery_environment.production.id
  name           = "Third Stage"

  # Optional
  description = "this is my first deployment stage"
  move_after  = qovery_deployment_stage.second_deployment_stage.id
}
