locals {
  donor_test_data    = jsondecode(file("${path.module}/files/test-data/donors.json"))
  campaign_test_data = jsondecode(file("${path.module}/files/test-data/campaigns.json"))
  cause_test_data    = jsondecode(file("${path.module}/files/test-data/causes.json"))
  donation_test_data = jsondecode(file("${path.module}/files/test-data/donations.json"))
}

# Seed Firestore with approvers
resource "random_string" "approver_doc_id" {
  count       = var.seed_test_data ? 1 : 0
  length      = 20
  special     = false
  min_numeric = 3
  min_lower   = 10
}

data "template_file" "approver" {
  count    = var.seed_test_data ? 1 : 0
  template = file("${path.module}/files/templates/approvers.tftpl")
  vars = {
    email = var.approver_email
  }
}

resource "google_firestore_document" "approvers" {
  project     = var.project_id
  count       = var.seed_test_data ? 1 : 0
  collection  = "approvers"
  document_id = random_string.approver_doc_id[count.index].result
  fields      = data.template_file.approver[count.index].rendered
}

# Seed test data to donors collection

data "template_file" "donors" {
  template = file("${path.module}/files/templates/donors.tftpl")
  count    = var.seed_test_data ? "${length(local.donor_test_data)}" : 0
  vars = {
    id              = local.donor_test_data[count.index].id
    name            = local.donor_test_data[count.index].data.name
    email           = local.donor_test_data[count.index].data.email
    mailing_address = local.donor_test_data[count.index].data.mailing_address
  }
}

resource "google_firestore_document" "donors" {
  project     = var.project_id
  count       = var.seed_test_data ? "${length(data.template_file.donors)}" : 0
  collection  = "donors"
  document_id = local.donor_test_data[count.index].id
  fields      = data.template_file.donors[count.index].rendered
}

# Seed test data to campaigns collection

data "template_file" "campaigns" {
  template = file("${path.module}/files/templates/campaigns.tftpl")
  count    = var.seed_test_data ? "${length(local.campaign_test_data)}" : 0
  vars = {
    name        = local.campaign_test_data[count.index].data.name
    description = local.campaign_test_data[count.index].data.description
    cause       = local.campaign_test_data[count.index].data.cause
    managers    = trim("[${join(",", local.campaign_test_data[count.index].data.managers)}]", "[]")
    goal        = local.campaign_test_data[count.index].data.goal
    imageUrl    = local.campaign_test_data[count.index].data.imageUrl
    active      = local.campaign_test_data[count.index].data.active
  }
}

resource "google_firestore_document" "campaigns" {
  project     = var.project_id
  count       = var.seed_test_data ? "${length(data.template_file.campaigns)}" : 0
  collection  = "campaigns"
  document_id = local.campaign_test_data[count.index].id
  fields      = data.template_file.campaigns[count.index].rendered
}

# Seed test data to causes collection

data "template_file" "causes" {
  template = file("${path.module}/files/templates/causes.tftpl")
  count    = var.seed_test_data ? "${length(local.cause_test_data)}" : 0
  vars = {
    name        = local.cause_test_data[count.index].data.name
    description = local.cause_test_data[count.index].data.description
    imageUrl    = local.cause_test_data[count.index].data.imageUrl
    active      = local.cause_test_data[count.index].data.active
  }
}

resource "google_firestore_document" "causes" {
  project     = var.project_id
  count       = var.seed_test_data ? "${length(data.template_file.causes)}" : 0
  collection  = "causes"
  document_id = local.cause_test_data[count.index].id
  fields      = data.template_file.causes[count.index].rendered
}

# Seed test data to donations collection

data "template_file" "donations" {
  template = file("${path.module}/files/templates/donations.tftpl")
  count    = var.seed_test_data ? "${length(local.donation_test_data)}" : 0
  vars = {
    campaign = local.donation_test_data[count.index].data.campaign
    donor    = local.donation_test_data[count.index].data.donor
    amount   = local.donation_test_data[count.index].data.amount
  }
}

resource "google_firestore_document" "donations" {
  project     = var.project_id
  count       = var.seed_test_data ? "${length(data.template_file.donations)}" : 0
  collection  = "donations"
  document_id = local.donation_test_data[count.index].id
  fields      = data.template_file.donations[count.index].rendered
}