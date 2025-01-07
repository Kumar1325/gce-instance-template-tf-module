module "sole_tenancy_vm" {
  source                = "../../"
  name                  = "sole-tenancy-vm-template"
  machine_type          = "e2-medium"
  region                = "us-central1"
  enable_sole_tenancy   = true
  sole_tenancy_key      = "compute.googleapis.com/node-group"
  sole_tenancy_operator = "IN"
  sole_tenancy_values   = ["sole-tenancy-group"]
  source_image          = "projects/debian-cloud/global/images/family/debian-11"
  cmek_key              = "projects/my-project/locations/global/keyRings/my-keyring/cryptoKeys/my-key"
}
