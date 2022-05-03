# The following will check if a app engine default service account exists
# If it already does, Terraform will not create an Appengine App
# This is a work around for Terraform being unable to truely destroy
# an app engine application
data "google_app_engine_default_service_account" "default" {
  project = var.project_id
}

resource "google_app_engine_application" "main" {
  count         = data.google_app_engine_default_service_account.default.unique_id == null ? 1 : 0
  project       = var.project_id
  location_id   = replace(trimspace(var.region), "/\\d+$/", "")
  database_type = "CLOUD_FIRESTORE"
  depends_on = [
    google_project_service.emblem_app_services
  ]
}
