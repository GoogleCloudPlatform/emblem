variable "project_id" {
  type        = string
  description = "Project ID of project to deploy resources to."
}

variable "approver_email" {
  type        = string
  description = "Email of initial user to add to Firebase as approver."
  default     = "user@example.com"
}
