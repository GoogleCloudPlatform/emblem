variable "google_ops_project_id" {
  type = string
}

variable "repo_owner" {
  type    = string
  default = "GoogleCloudPlatform"
}

variable "repo_name" {
  type    = string
  default = "emblem"
}

data "google_project" "ops_project" {
  project_id = var.google_ops_project_id
}

variable "google_region" {
  type    = string
  default = "us-central1"
}
