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
