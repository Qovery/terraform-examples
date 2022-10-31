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

variable "medusa_jwt_secret" {
  type    = string
  default = "your-super-secret" # TO CHANGE FOR PRODUCTION
}

variable "medusa_cookie_secret" {
  type    = string
  default = "your-super-secret-pt2" # TO CHANGE FOR PRODUCTION
}

variable "toto_secret" {
  type    = string
}
