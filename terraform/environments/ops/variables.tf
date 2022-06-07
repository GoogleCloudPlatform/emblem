variable "project_id" {
  type        = string
  description = ""
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = ""
}

variable "setup_cd_system" {
  type        = bool
  default     = false
  description = "Create deployment triggers. Enable only if Cloud Build has been granted GitHub access."
}

variable "deploy_session_bucket" {
  type        = bool
  default     = true
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

