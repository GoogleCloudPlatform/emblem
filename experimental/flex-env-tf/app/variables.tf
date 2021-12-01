# Project IDs
variable "google_ops_project_id" {
  description = "Google Cloud Project ID (Ops)"
  type        = string
}

variable "google_project_id" {
  description = "Google Cloud Project ID (App)"
  type        = string
}

variable "region" {
  description = "Google Cloud Region"
  type        = string
  default     = "us-central1"
}
