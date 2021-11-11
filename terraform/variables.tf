variable "google_region" {
  type    = string
  default = "us-central1"
}

# Project IDs
variable "google_ops_project_id" {
  type = string
}

variable "google_prod_project_id" {
  type = string
}

variable "google_stage_project_id" {
  type = string
}

# Session bucket ID
variable "session_bucket_id" {
  type = string
}
