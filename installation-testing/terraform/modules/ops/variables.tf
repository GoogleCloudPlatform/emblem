variable "project_id" {
  description = "Google Cloud Project to deploy module resources."
  type        = string
}

variable "nightly_topic_id" {
  description = "The Pub/Sub topic used to trigger nightly builds."
  type        = string
  default     = "nightly"
}

variable "repo_owner" {
  description = "The owner of the triggering GitHub repo (GoogleCloudPlatform)."
  type        = string
}

variable "repo_name" {
  description = "The name of the triggering GitHub repo (emblem)."
  type        = string
}
