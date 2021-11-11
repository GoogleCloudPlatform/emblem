module "application_service" {
  for_each = {
    prod  = var.google_prod_project_id
    stage = var.google_stage_project_id
  }
  source                         = "./application"
  environment                    = each.key
  google_project_id              = each.value
}
