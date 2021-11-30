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

# Finding good documentation on Terraform maps can be difficult.
# This was a useful resource:
# https://operatingops.com/2021/05/31/terraform-map-and-object-patterns/
variable "environments" {
  type        = map(string)
  description = "Define the application environments using {\"EnvironmentName\": \"GoogleCloudProjectId\"}"
  validation {
    # Ensure a staging environment is defined.
    condition     = contains(keys(var.environments), "staging")
    error_message = "Cloud Build configuration requires 'staging' and optionally 'prod'."
  }
}
