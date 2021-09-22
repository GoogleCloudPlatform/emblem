variable "google_project_id" {
  type    = string
}

variable "google_region" {
  type    = string
  default = "us-central1"
}

variable "release_type" {
  type = string
  default = "stage"

  validation {
    condition     = contains(["prod", "stage"], var.release_type)
    error_message = "Valid values for release_type are: (prod, stage)."
  } 
}
