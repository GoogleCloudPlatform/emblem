locals {
  donor_test_data    = jsondecode(file("${path.module}/files/test-data/donors.json"))
  campaign_test_data = jsondecode(file("${path.module}/files/test-data/campaigns.json"))
  cause_test_data    = jsondecode(file("${path.module}/files/test-data/causes.json"))
  donation_test_data = jsondecode(file("${path.module}/files/test-data/donations.json"))
}

# Seed Firestore with approvers
resource "random_string" "approver_doc_id" {
  length      = 20
  special     = false
  min_numeric = 3
  min_lower   = 10
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
  for_each = { for entry in local.donor_test_data : entry.id => entry }
  vars = {
    name            = each.value.data.name
    email           = each.value.data.email
    mailing_address = each.value.data.mailing_address
  }
}

resource "google_firestore_document" "donors" {
  project     = var.project_id
  for_each    = data.template_file.donors
  collection  = "donors"
  document_id = each.key
  fields      = each.value["rendered"]
}

# Seed test data to campaigns collection

data "template_file" "campaigns" {
  template = file("${path.module}/files/templates/campaigns.tftpl")
  for_each = { for entry in local.campaign_test_data : entry.id => entry }
  vars = {
    name        = each.value.data.name
    description = each.value.data.description
    cause       = each.value.data.cause
    managers    = trim("[${join(",", each.value.data.managers)}]", "[]")
    goal        = each.value.data.goal
    imageUrl    = each.value.data.imageUrl
    active      = each.value.data.active
  }
}

resource "google_firestore_document" "campaigns" {
  project     = var.project_id
  for_each    = data.template_file.campaigns
  collection  = "campaigns"
  document_id = each.key
  fields      = each.value["rendered"]
}

# Seed test data to causes collection

data "template_file" "causes" {
  template = file("${path.module}/files/templates/causes.tftpl")
  for_each = { for entry in local.cause_test_data : entry.id => entry }
  vars = {
    name        = each.value.data.name
    description = each.value.data.description
    imageUrl    = each.value.data.imageUrl
    active      = each.value.data.active
  }
}

resource "google_firestore_document" "causes" {
  project     = var.project_id
  for_each    = data.template_file.causes
  collection  = "causes"
  document_id = each.key
  fields      = each.value["rendered"]
}

# Seed test data to donations collection

data "template_file" "donations" {
  template = file("${path.module}/files/templates/donations.tftpl")
  for_each = { for entry in local.donation_test_data : entry.id => entry }
  vars = {
    campaign = each.value.data.campaign
    donor    = each.value.data.donor
    amount   = each.value.data.amount
  }
}

resource "google_firestore_document" "donations" {
  project     = var.project_id
  for_each    = data.template_file.donations
  collection  = "donations"
  document_id = each.key
  fields      = each.value["rendered"]
}