/**********************************************************************
 * This file documents all resources that aren't environment specific *
 **********************************************************************/

# GCP Project references
data "google_project" "ops_project" {
  project_id = var.google_ops_project_id
}

data "google_project" "prod_project" {
  project_id = var.google_prod_project_id
}

data "google_project" "stage_project" {
  project_id = var.google_stage_project_id
}

# Providers
provider "google" {
  alias   = "ops"
  project = data.google_project.ops_project.project_id
  region  = var.google_region
}

provider "google" {
  alias   = "prod"
  project = data.google_project.prod_project.project_id
  region  = var.google_region
}

provider "google" {
  alias   = "stage"
  project = data.google_project.stage_project.project_id
  region  = var.google_region
}

provider "google-beta" {
  alias   = "ops"
  project = data.google_project.ops_project.project_id
  region  = var.google_region
}

# OAuth 2.0 secrets
# These secret resources are REQUIRED, but configuring them is OPTIONAL.
# To avoid leaking secret data, we set their values directly with `gcloud`.
# (Otherwise, Terraform would store secret data unencrypted in .tfstate files.)

# TODO: prod and staging should use different secrets
# See the following GitHub issue:
#   https://github.com/GoogleCloudPlatform/emblem/issues/263
resource "google_secret_manager_secret" "client-id-secret" {
  project   = data.google_project.ops_project.project_id
  secret_id = "oauth-client-id"
  replication {
    automatic = "true"
  }
}

resource "google_secret_manager_secret" "client-secret-secret" {
  project   = data.google_project.ops_project.project_id
  secret_id = "oauth-client-secret"
  replication {
    automatic = "true"
  }
}
