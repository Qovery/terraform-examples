variable "qovery_organization_id" {
  type = string
}

variable "qovery_access_token" {
  type = string
}

variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

variable "strapi_admin_jwt_secret" {
  type    = string
  default = "erM62KSzpfgXdp1nYCh/Qg" # TO CHANGE FOR PRODUCTION
}

variable "strapi_api_token_salt" {
  type    = string
  default = "mdmf4fu2UKVWFABOH8giHQ" # TO CHANGE FOR PRODUCTION
}

variable "strapi_app_keys" {
  type    = string
  default = "BNkCdQkXQ6IG6RgPEA3Hnw" # TO CHANGE FOR PRODUCTION
}
