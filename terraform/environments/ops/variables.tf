variable "project_id" {
  type        = string
  description = ""
}

# Test against the `prod` version of the Content API
# - We care primarily about testing the **website** component, not the API itself.
# - If you want to test the API as well, you can use the `stage` API version instead.
variable "prod_project_id" {
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

variable "setup_e2e_tests" {
  type        = bool
  default     = false
  description = "Create E2E testing triggers for the Website component. Enable only if Cloud Build has been granted GitHub access."
}
