module "advanced_vm" {
  source                = "../../"
  name                  = "advanced-vm-template"
  machine_type          = "e2-highmem-8"
  region                = "us-central1"
  enable_confidential_vm = true
  shielded_secure_boot  = true
  shielded_vtpm         = true
  shielded_integrity_monitoring = true
  additional_disks      = [
    {
      auto_delete = true
      disk_size   = 100
      disk_type   = "pd-balanced"
    }
  ]
  source_image          = "projects/debian-cloud/global/images/family/debian-11"
  cmek_key              = "projects/my-project/locations/global/keyRings/my-keyring/cryptoKeys/my-key"
}
