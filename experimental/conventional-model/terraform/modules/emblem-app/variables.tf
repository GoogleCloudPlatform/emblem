variable "project_id" {
  type = string
}

variable "enable_apis" {
  type        = bool
  description = "Toggle to include required APIs."
  default     = true
}

variable "region" {
  type    = string
  default = "us-central1"
}
