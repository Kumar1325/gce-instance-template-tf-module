module "confidential_vm" {
  source                = "../../"
  name                  = "confidential-vm-template"
  machine_type          = "n2d-standard-4"
  region                = "us-central1"
  enable_confidential_vm = true
  source_image          = "projects/debian-cloud/global/images/family/debian-11"
  cmek_key              = "projects/my-project/locations/global/keyRings/my-keyring/cryptoKeys/my-key"
}
