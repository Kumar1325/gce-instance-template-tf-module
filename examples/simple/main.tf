module "simple_vm" {
  source                = "../../"
  name                  = "simple-vm-template"
  machine_type          = "e2-medium"
  region                = "us-central1"
  source_image          = "projects/debian-cloud/global/images/family/debian-11"
  cmek_key              = "projects/my-project/locations/global/keyRings/my-keyring/cryptoKeys/my-key"
}
