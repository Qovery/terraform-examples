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
  instance_type     = "t3a.medium"
  min_running_nodes = 3
  max_running_nodes = 4
}

resource "qovery_project" "my_project" {
  organization_id = var.qovery_organization_id
  name            = "Lifecycle-job"
}

resource "qovery_environment" "production" {
  project_id = qovery_project.my_project.id
  name       = "production"
  mode       = "PRODUCTION"
  cluster_id = qovery_cluster.my_cluster.id
}

# create and deploy lifecycle job triggered on start and on stop
resource "qovery_job" "lifecycle-job-on-start-on-stop" {
  environment_id = qovery_environment.production.id
  name           = "lifecycle-job-on-start-on-stop"
  
  cpu = 100
  memory = 350
  
  max_duration_seconds = 60
  max_nb_restart = 1
  
  port = 4000
  
  auto_preview = false
  
  schedule = {
    on_start = {
      entrypoint = ""
      arguments = []
    }
    on_stop = {
      entrypoint = ""
      arguments = []
    }
  }
  
  source = {
    docker = {
      dockerfile_path = "Dockerfile"
      git_repository = {
        url = "https://github.com/Qovery/terraform-provider-testing.git"
        branch = "job-echo-n-seconds"
        root_path = "/"
      }
    }
  }

  environment_variables = [
      {
        key   = "PORT"
        value = "4000"
      },
      {
        key   = "DURATION_SECONDS"
        value = "15"
      },
  ]

  secrets = [
      {
        key   = "JOB_SECRET"
        value = "my job secret"
      },
  ]
}

# create and deploy lifecycle job on delete
resource "qovery_job" "lifecycle-job-on-delete" {
  environment_id = qovery_environment.production.id
  name           = "lifecycle-job-on-delete"
  
  cpu = 100
  memory = 350
  
  max_duration_seconds = 60
  max_nb_restart = 1
  
  port = 4000
  
  auto_preview = false
  
  schedule = {
    on_delete = {
      entrypoint = ""
      arguments = []
    }
  }
  
  source = {
    docker = {
      dockerfile_path = "Dockerfile"
      git_repository = {
        url = "https://github.com/Qovery/terraform-provider-testing.git"
        branch = "job-echo-n-seconds"
        root_path = "/"
      }
    }
  }

  environment_variables = [
      {
        key   = "PORT"
        value = "4000"
      },
      {
        key   = "DURATION_SECONDS"
        value = "15"
      },
  ]

  secrets = [
      {
        key   = "JOB_SECRET"
        value = "my job secret"
      },
  ]
}

resource "qovery_deployment" "prod_deployment" {
  environment_id = qovery_environment.production.id
  desired_state  = "RUNNING"
}
