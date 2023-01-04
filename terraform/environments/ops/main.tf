module "emblem_ops" {
  source          = "../../modules/ops"
  project_id      = var.project_id
  region          = var.region
  setup_cd_system = var.setup_cd_system
  repo_owner      = var.repo_owner
  repo_name       = var.repo_name
}

data "google_cloud_run_service" "website_e2e_test_content_api" {
  project  = var.app_project_id
  name     = "content-api"
  location = var.region
}

module "website_e2e_test" {
  source          = "../../modules/website-e2e-test"
  count           = var.setup_e2e_tests && var.setup_cd_system ? 1 : 0
  project_id      = var.project_id
  region          = var.region
  repo_owner      = var.repo_owner
  repo_name       = var.repo_name
  content_api_url = data.google_cloud_run_service.website_e2e_test_content_api.status[0].url
}
