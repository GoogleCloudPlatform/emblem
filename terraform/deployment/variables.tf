variable "google_app_project_id" {
  type = string
}

variable "google_ops_project_id" {
  type = string
}

variable "google_region" {
  type    = string
  default = "us-central1"
}

variable "deployment_type" {
  type    = string
  default = "stage"

  validation {
    condition     = contains(["prod", "stage"], var.deployment_type)
    error_message = "Valid values for deployment_type are: (prod, stage)."
  }
}
