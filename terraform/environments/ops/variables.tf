variable "project_id" {
  type        = string
  description = ""
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = ""
}

variable "deploy_triggers" {
  type        = bool
  default     = false
  description = ""
}

variable "repo_owner" {
  type        = string
  description = ""
  default     = ""
}

variable "repo_name" {
  type        = string
  description = ""
  default     = ""
}

variable "environment_project_ids" {
  type        = map(string)
  description = "Map containing environment names and project IDs"
}
