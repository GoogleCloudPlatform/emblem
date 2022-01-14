output "project_number" {
  value = data.google_project.main.number
}

output "website_manager" {
  value = google_service_account.website_manager.email
}