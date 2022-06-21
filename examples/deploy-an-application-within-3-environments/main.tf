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
  name              = "URL Shortener"
  access_key_id     = var.aws_access_key_id
  secret_access_key = var.aws_secret_access_key
}

resource "qovery_cluster" "production_cluster" {
  organization_id   = var.qovery_organization_id
  credentials_id    = qovery_aws_credentials.my_aws_creds.id
  name              = "Production cluster"
  description       = "Terraform prod demo cluster"
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

resource "qovery_cluster" "staging_cluster" {
  organization_id   = var.qovery_organization_id
  credentials_id    = qovery_aws_credentials.my_aws_creds.id
  name              = "Staging cluster"
  description       = "Terraform staging demo cluster"
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

resource "qovery_cluster" "dev_cluster" {
  organization_id   = var.qovery_organization_id
  credentials_id    = qovery_aws_credentials.my_aws_creds.id
  name              = "Dev cluster"
  description       = "Terraform dev demo cluster"
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
  name            = "Multi-env Project"

  depends_on = [
    qovery_cluster.production_cluster
  ]
}

resource "qovery_environment" "production" {
  project_id = qovery_project.my_project.id
  name       = "production"
  mode       = "PRODUCTION"
  cluster_id = qovery_cluster.production_cluster.id

  depends_on = [
    qovery_project.my_project
  ]
}

resource "qovery_database" "production_psql_database" {
  environment_id = qovery_environment.production.id
  name           = "strapi db"
  type           = "POSTGRESQL"
  version        = "13"
  mode           = "MANAGED" # Use AWS RDS for PostgreSQL (backup and PITR automatically configured by Qovery)
  storage        = 10 # 10GB of storage
  accessibility  = "PRIVATE" # do not make it publicly accessible
  state          = "RUNNING"

  depends_on = [
    qovery_environment.production,
  ]
}

resource "qovery_application" "production_strapi_app" {
  environment_id = qovery_environment.production.id
  name           = "strapi app"
  cpu            = 1000
  memory         = 512
  state          = "RUNNING"
  git_repository = {
    url       = "https://github.com/evoxmusic/strapi-v4.git"
    branch    = "main"
    root_path = "/"
  }
  build_mode            = "DOCKER"
  dockerfile_path       = "Dockerfile"
  min_running_instances = 1
  max_running_instances = 1
  ports                 = [
    {
      internal_port       = 1337
      external_port       = 443
      protocol            = "HTTP"
      publicly_accessible = true
    }
  ]
  environment_variables = [
    {
      key   = "PORT"
      value = "1337"
    },
    {
      key   = "HOST"
      value = "0.0.0.0"
    },
    {
      key   = "DATABASE_HOST"
      value = qovery_database.production_psql_database.internal_host
    },
    {
      key   = "DATABASE_PORT"
      value = qovery_database.production_psql_database.port
    },
    {
      key   = "DATABASE_USERNAME"
      value = qovery_database.production_psql_database.login
    },
    {
      key   = "DATABASE_NAME"
      value = "postgres"
    },
  ]
  secrets = [
    {
      key   = "ADMIN_JWT_SECRET"
      value = var.strapi_admin_jwt_secret
    },
    {
      key   = "API_TOKEN_SALT"
      value = var.strapi_api_token_salt
    },
    {
      key   = "APP_KEYS"
      value = var.strapi_app_keys
    },
    {
      key   = "DATABASE_PASSWORD"
      value = qovery_database.production_psql_database.password
    }
  ]

  depends_on = [
    qovery_environment.production,
    qovery_database.production_psql_database,
  ]
}

resource "qovery_environment" "staging" {
  project_id = qovery_project.my_project.id
  name       = "staging"
  mode       = "STAGING"
  cluster_id = qovery_cluster.staging_cluster.id

  depends_on = [
    qovery_project.my_project
  ]
}

resource "qovery_database" "staging_psql_database" {
  environment_id = qovery_environment.staging.id
  name           = "strapi db"
  type           = "POSTGRESQL"
  version        = "13"
  mode           = "MANAGED" # Use AWS RDS for PostgreSQL (backup and PITR automatically configured by Qovery)
  storage        = 10 # 10GB of storage
  accessibility  = "PRIVATE" # do not make it publicly accessible
  state          = "RUNNING"

  depends_on = [
    qovery_environment.staging,
  ]
}

resource "qovery_application" "staging_strapi_app" {
  environment_id = qovery_environment.staging.id
  name           = "strapi app"
  cpu            = 1000
  memory         = 512
  state          = "RUNNING"
  git_repository = {
    url       = "https://github.com/evoxmusic/strapi-v4.git"
    branch    = "main"
    root_path = "/"
  }
  build_mode            = "DOCKER"
  dockerfile_path       = "Dockerfile"
  min_running_instances = 1
  max_running_instances = 1
  ports                 = [
    {
      internal_port       = 1337
      external_port       = 443
      protocol            = "HTTP"
      publicly_accessible = true
    }
  ]
  environment_variables = [
    {
      key   = "PORT"
      value = "1337"
    },
    {
      key   = "HOST"
      value = "0.0.0.0"
    },
    {
      key   = "DATABASE_HOST"
      value = qovery_database.staging_psql_database.internal_host
    },
    {
      key   = "DATABASE_PORT"
      value = qovery_database.staging_psql_database.port
    },
    {
      key   = "DATABASE_USERNAME"
      value = qovery_database.staging_psql_database.login
    },
    {
      key   = "DATABASE_NAME"
      value = "postgres"
    },
  ]
  secrets = [
    {
      key   = "ADMIN_JWT_SECRET"
      value = var.strapi_admin_jwt_secret
    },
    {
      key   = "API_TOKEN_SALT"
      value = var.strapi_api_token_salt
    },
    {
      key   = "APP_KEYS"
      value = var.strapi_app_keys
    },
    {
      key   = "DATABASE_PASSWORD"
      value = qovery_database.staging_psql_database.password
    }
  ]

  depends_on = [
    qovery_environment.staging,
    qovery_database.staging_psql_database,
  ]
}

resource "qovery_environment" "dev" {
  project_id = qovery_project.my_project.id
  name       = "dev"
  mode       = "DEVELOPMENT"
  cluster_id = qovery_cluster.dev_cluster.id

  depends_on = [
    qovery_project.my_project
  ]
}

resource "qovery_database" "dev_psql_database" {
  environment_id = qovery_environment.dev.id
  name           = "strapi db"
  type           = "POSTGRESQL"
  version        = "13"
  mode           = "CONTAINER" # Use a container for development purpose
  storage        = 10 # 10GB of storage
  accessibility  = "PRIVATE" # do not make it publicly accessible
  state          = "RUNNING"

  depends_on = [
    qovery_environment.dev,
  ]
}

resource "qovery_application" "staging_strapi_app" {
  environment_id = qovery_environment.staging.id
  name           = "strapi app"
  cpu            = 1000
  memory         = 512
  state          = "RUNNING"
  git_repository = {
    url       = "https://github.com/evoxmusic/strapi-v4.git"
    branch    = "main"
    root_path = "/"
  }
  build_mode            = "DOCKER"
  dockerfile_path       = "Dockerfile"
  min_running_instances = 1
  max_running_instances = 1
  ports                 = [
    {
      internal_port       = 1337
      external_port       = 443
      protocol            = "HTTP"
      publicly_accessible = true
    }
  ]
  environment_variables = [
    {
      key   = "PORT"
      value = "1337"
    },
    {
      key   = "HOST"
      value = "0.0.0.0"
    },
    {
      key   = "DATABASE_HOST"
      value = qovery_database.dev_psql_database.internal_host
    },
    {
      key   = "DATABASE_PORT"
      value = qovery_database.dev_psql_database.port
    },
    {
      key   = "DATABASE_USERNAME"
      value = qovery_database.dev_psql_database.login
    },
    {
      key   = "DATABASE_NAME"
      value = "postgres"
    },
  ]
  secrets = [
    {
      key   = "ADMIN_JWT_SECRET"
      value = var.strapi_admin_jwt_secret
    },
    {
      key   = "API_TOKEN_SALT"
      value = var.strapi_api_token_salt
    },
    {
      key   = "APP_KEYS"
      value = var.strapi_app_keys
    },
    {
      key   = "DATABASE_PASSWORD"
      value = qovery_database.dev_psql_database.password
    }
  ]

  depends_on = [
    qovery_environment.dev,
    qovery_database.dev_psql_database,
  ]
}
