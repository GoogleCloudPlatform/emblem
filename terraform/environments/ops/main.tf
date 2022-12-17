module "emblem_ops" {
  source          = "../../modules/ops"
  project_id      = var.project_id
  region          = var.region
  setup_cd_system = var.setup_cd_system
  repo_owner      = var.repo_owner
  repo_name       = var.repo_name
}

module "website_e2e_test" {
  source          = "../../modules/website-e2e-test"
  count           = var.setup_e2e_tests ? 1 : 0
  project_id      = var.project_id
  region          = var.region
  repo_owner      = var.repo_owner
  repo_name       = var.repo_name
}
