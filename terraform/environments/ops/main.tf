module "emblem_ops" {
  source          = "../../modules/ops"
  project_id      = var.project_id
  region          = var.region
  setup_cd_system = var.setup_cd_system
  repo_owner      = var.repo_owner
  repo_name       = var.repo_name
}

##############################
# Website end-to-end testing #
##############################
data "google_cloud_run_service" "content_api" {
  project  = var.prod_project_id
  name     = "content-api"
  location = var.region
  count    = var.setup_e2e_tests ? 1 : 0
}

module "website_e2e_test" {
  source          = "../../modules/website-e2e-test"
  count           = var.setup_e2e_tests ? 1 : 0
  project_id      = var.project_id
  region          = var.region
  repo_owner      = var.repo_owner
  repo_name       = var.repo_name
  content_api_url = data.google_cloud_run_service.content_api[0].status[0].url
}
