provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_kms_key_ring" "keyring" {
  name     = "shielded-tpl-keyring"
  location = var.region
}

resource "google_kms_crypto_key" "example_key" {
  name            = "crypto-key-example"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = "100000s"
}

# Grant Permission to Compute Engine Service Agent
resource "google_kms_crypto_key_iam_member" "compute_engine_service_agent" {
  crypto_key_id = google_kms_crypto_key.example_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com"
}

module "shielded_vm" {
  source          = "../../"
  name_prefix     = "shielded-vm-tpl"
  machine_type    = "n1-standard-1"
  region          = var.region
  network         = var.network
  subnetwork      = var.subnetwork
  tags            = var.tags
  labels          = var.labels
  service_account = var.service_account

  enable_shielded_vm = true
  shielded_instance_config = {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
  source_image = "projects/debian-cloud/global/images/family/debian-11"

  additional_disks = [
    {
      disk_name    = "disk-1"
      device_name  = "disk-1"
      disk_size_gb = 10
      disk_type    = "pd-standard"
      auto_delete  = "true"
      boot         = "false"
      disk_labels  = { "foo" : "bar" }
    }
  ]
  disk_encryption_key = google_kms_crypto_key.example_key.id
}
