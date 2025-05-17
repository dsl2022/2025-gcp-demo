# variables.tf

variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "image" {
  description = "Docker image (including tag) to deploy"
  type        = string
}