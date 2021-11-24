provider "google" {
  region = var.region
}

# Required to manage Artifact Registry.
provider "google-beta" {
  region = var.region
}
