# Project IDs
variable "project_id" {
  description = "Google Cloud Project to deploy module resources."
  type        = string
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "Google Cloud Region"
}

variable "repo_owner" {
  description = "Repo Owner (GoogleCloudPlatform)"
  type        = string
}

variable "repo_name" {
  description = "Repo Name (emblem)"
  type        = string
}

variable "enable_apis" {
  type        = bool
  description = "Toggle to include required APIs."
  default     = true
}
