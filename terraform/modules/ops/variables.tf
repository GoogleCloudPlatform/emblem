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

variable "deploy_triggers" {
  type        = bool
  default     = false
  description = "This value should only be changed to true after connecting a Github repository to your project."
}

variable "environment_project_ids" {
  type        = map(string)
  description = "Map containing environment names and project IDs"
}
