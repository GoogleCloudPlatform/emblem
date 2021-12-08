variable "google_project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

# Sets the time-to-live in days for user sessions.
variable "session_bucket_ttl" {
  type    = number
  default = 14
}
