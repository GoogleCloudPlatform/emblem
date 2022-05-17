variable "project_id" {
  type        = string
  description = ""
}
variable "region" {
  type        = string
  default     = "us-central1"
  description = ""
}
variable "repo_owner" {
  type        = string
  description = ""
}
variable "repo_name" {
  type        = string
  description = ""
}

variable "deploy_triggers" {
  type        = bool
  default     = false
  description = "This value should only be changed to true after connecting a Github repository to your project."
}