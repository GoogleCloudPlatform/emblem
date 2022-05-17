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

variable "nightly_build_topic" {
  description = "The topic name used by Cloud Scheduler to trigger nightly builds"
  type        = string
  default     = "nightly-builds"
}
