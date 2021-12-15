output "project_number" {
  value = data.google_project.main.number
}

output "cloud_run_manager" {
  value = google_service_account.cloud_run_manager.email
}