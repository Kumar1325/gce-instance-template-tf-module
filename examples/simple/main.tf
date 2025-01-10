provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_kms_key_ring" "keyring" {
  name     = "simple-keyring-example"
  location = var.region
}

resource "google_kms_crypto_key" "example-key" {
  name            = "crypto-key-example"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = "100000s"
}

# Grant Permission to Compute Engine Service Agent
resource "google_kms_crypto_key_iam_member" "compute_engine_service_agent" {
  crypto_key_id = google_kms_crypto_key.example-key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com"
}

module "simple_vm" {
  source              = "../../"
  name_prefix         = "simple-vm-template"
  machine_type        = "e2-medium"
  region              = var.region
  network             = var.network
  subnetwork          = var.subnetwork
  tags                = var.tags
  labels              = var.labels
  service_account     = var.service_account
  source_image        = "projects/debian-cloud/global/images/family/debian-11"
  disk_encryption_key = google_kms_crypto_key.example-key.id
}

resource "google_compute_instance_from_template" "tpl" {
  name = "instance-from-template"
  zone = "us-central1-a"

  source_instance_template = module.simple_vm.self_link_unique

  // Override fields from instance template
  can_ip_forward = false
  labels = {
    name = "test-instance"
  }
}