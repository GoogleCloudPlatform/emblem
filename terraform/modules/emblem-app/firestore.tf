locals {
  donor_test_data = jsondecode(file("${path.module}/files/donors.json"))
}

# Seed Firestore with approvers
resource "random_string" "approver_doc_id" {
  length           = 20
  special          = false
  min_numeric      = 3
  min_lower = 10
}

data "template_file" "approver" {
  template = file("${path.module}/files/templates/approvers.tftpl")
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

# Seed test data to donors collection

data "template_file" "donors" {
  template = file("${path.module}/files/templates/donors.tftpl")
  count = "${length(local.donor_test_data)}"
  vars = {
    id = local.donor_test_data[count.index].id
    name = local.donor_test_data[count.index].data.name
    email = local.donor_test_data[count.index].data.email
    mailing_address = local.donor_test_data[count.index].data.mailing_address
  }
}

resource "google_firestore_document" "donors" {
  count = "${length(data.template_file.donors)}"
  collection  = "donors"
  document_id = local.donor_test_data[count.index].id
  fields      = data.template_file.donors[count.index].rendered
}