provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_kms_key_ring" "keyring" {
  name     = "keyring-example"
  location = "global"
}

resource "google_kms_crypto_key" "example-key" {
  name            = "crypto-key-example"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = "100000s"

  lifecycle {
    prevent_destroy = true
  }
}module "simple_vm" {
  source                = "../../"
  name_prefix           = "simple-vm-template-"
  machine_type          = "e2-medium"
  region                = "us-central1"
  source_image          = "projects/debian-cloud/global/images/family/debian-11"
  cmek_key              = "projects/my-project/locations/global/keyRings/my-keyring/cryptoKeys/my-key"
}
