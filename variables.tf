# Input variable definitions

variable "application_name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Application environment"
  type        = string
}

variable "owner_team" {
  description = "Owener Application team"
  type        = string
}

variable "cognito_client_id" {
  description = "Cognito Client ID"
  type        = string
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  type        = string
}