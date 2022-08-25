# Seed Firestore with approvers
resource "random_string" "approver_doc_id" {
  length           = 20
  special          = false
  min_numeric      = 3
  min_lower = 10
}

data "template_file" "approver" {
  template = file("${path.module}/files/approvers.tftpl")
  vars = {
    email = var.approver_email
  }
}

resource "google_firestore_document" "approvers" {
  project     = var.project_id
  collection  = "approvers"
  document_id = random_string.approver_doc_id.result
  fields      = data.template_file.approver.rendered
}
