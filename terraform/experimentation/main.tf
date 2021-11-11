# Testing initiating 1 or 3 projects

data "google_project" "ops_project" {
  project_id = var.google_ops_project_id
}

data "google_project" "prod_project" {
  project_id = var.google_prod_project_id
}

data "google_project" "stage_project" {
  project_id = var.google_stage_project_id
}