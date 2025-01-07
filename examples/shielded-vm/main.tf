module "shielded_vm" {
  source                    = "../../"
  name                      = "shielded-vm-template"
  machine_type              = "e2-medium"
  region                    = "us-central1"
  shielded_secure_boot      = true
  shielded_vtpm             = true
  shielded_integrity_monitoring = true
  source_image              = "projects/debian-cloud/global/images/family/debian-11"
  cmek_key                  = "projects/my-project/locations/global/keyRings/my-keyring/cryptoKeys/my-key"
}
