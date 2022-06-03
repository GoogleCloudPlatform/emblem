variable "environment_project_ids" {
  type = map(string)
  description = "Map containing environment names and project IDs"
}

variable "project_id" {
  type        = string
  description = "Google Cloud Project to deploy triggers resources."
}

variable "github_url" {
  type = string
}