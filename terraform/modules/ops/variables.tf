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
  default     = ""
}

variable "repo_name" {
  description = "Repo Name (emblem)"
  type        = string
  default     = ""
}

variable "enable_apis" {
  type        = bool
  description = "Toggle to include required APIs."
  default     = true
}

variable "setup_cd_system" {
  type        = bool
  default     = false
  description = "Create deployment triggers. Enable only if Cloud Build has been granted GitHub access."
}

variable "setup_e2e_tests" {
  type        = bool
  default     = false
  description = "Create E2E testing triggers for the Website component. Enable only if Cloud Build has been granted GitHub access."
}
