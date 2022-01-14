output "project_number" {
  value = data.google_project.main.number
}

output "cloud_run_manager" {
  value = google_service_account.cloud_run_manager.email
}

output "api_manager" {
  value = google_service_account.api_manager.email
}

output "website_manager" {
  value = google_service_account.website_manager.email
}
