variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "image" {
  description = "Docker image (including tag) to deploy"
  type        = string
}

variable "region" {
  description = "Region for Cloud SQL instance"
  type        = string
  default     = "us-central1"
}

variable "db_instance_name" {
  description = "Cloud SQL instance name"
  type        = string
  default     = "transfer-db"
}

variable "db_database_name" {
  description = "Name of the Postgres database to create"
  type        = string
  default     = "ledger"
}

variable "db_username" {
  description = "Database user for the application"
  type        = string
  default     = "transfer_user"
}

variable "db_password" {
  description = "Password for the database user"
  type        = string
  sensitive   = true
}