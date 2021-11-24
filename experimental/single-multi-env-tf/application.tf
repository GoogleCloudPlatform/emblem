module "application" {
  for_each = var.environments
  source            = "./application"
  environment       = each.key
  google_project_id = each.value
}
