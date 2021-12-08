# Project IDs
variable "google_ops_project_id" {
  description = "Google Cloud Project ID (Ops)"
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