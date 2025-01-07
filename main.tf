locals {
  source_image     = var.source_image != "" ? var.source_image : data.google_compute_image.image.self_link

  # NOTE: Even if all the shielded_instance_config or confidential_instance_config
  # values are false, if the config block exists and an unsupported image is chosen,
  # the apply will fail so we use a single-value array with the default value to
  # initialize the block only if it is enabled.
  shielded_vm_configs = var.enable_shielded_vm ? [true] : []

  confidential_terminate_condition = var.enable_confidential_vm && (var.confidential_instance_type != "SEV" || var.min_cpu_platform != "AMD Milan")
  on_host_maintenance = (
    var.preemptible || var.spot || local.confidential_terminate_condition
    ? "TERMINATE"
    : var.on_host_maintenance
  )

  # must be set to "AMD Milan" if confidential_instance_type is set to "SEV_SNP", or this will fail to create the VM.
  min_cpu_platform = var.confidential_instance_type == "SEV_SNP" ? "AMD Milan" : var.min_cpu_platform

  automatic_restart = (
    # must be false when preemptible or spot is true
    var.preemptible || var.spot ? false : var.automatic_restart
  )
  preemptible = (
    # must be true when preemtible or spot is true
    var.preemptible || var.spot ? true : false
  )
}

data "google_compute_image" "image" {
  family  = var.source_image_family
  project = var.source_image_project
}

resource "google_compute_instance_template" "default" {
  name                    = var.name
  machine_type            = var.machine_type
  region                  = var.region
  can_ip_forward          = false
  description             = var.description
  project                = var.project_id
  labels                  = var.labels
  metadata                = var.metadata
  tags                    = var.tags
  min_cpu_platform        = local.min_cpu_platform
  metadata_startup_script = var.startup_script

  dynamic "shielded_instance_config" {
    for_each = local.shielded_vm_configs
    content {
      enable_secure_boot          = lookup(var.shielded_instance_config, "enable_secure_boot", shielded_instance_config.value)
      enable_vtpm                 = lookup(var.shielded_instance_config, "enable_vtpm", shielded_instance_config.value)
      enable_integrity_monitoring = lookup(var.shielded_instance_config, "enable_integrity_monitoring", shielded_instance_config.value)
    }
  }

  confidential_instance_config {
    enable_confidential_compute = var.enable_confidential_vm
    confidential_instance_type  = var.confidential_instance_type
  }

  scheduling {
    on_host_maintenance = local.on_host_maintenance
    automatic_restart   = local.automatic_restart
    preemptible         = var.preemptible
    node_affinities = var.enable_sole_tenancy ? [{
      key      = var.sole_tenancy_key
      operator = var.sole_tenancy_operator
      values   = var.sole_tenancy_values
    }] : null
  }

  disk {
    auto_delete       = true
    boot              = true
    source_image      = local.source_image
    disk_size_gb      = var.disk_size
    disk_type         = var.disk_type
    lables            = var.disk_labels
    kms_key_self_link = var.cmek_key
  }

  dynamic "additional_disks" {
    for_each = var.additional_disks
    content {
      auto_delete       = lookup(additional_disks.value, "auto_delete", true)
      boot              = false
      source_image      = lookup(additional_disks.value, "source_image", null)
      disk_size_gb      = lookup(additional_disks.value, "disk_size", null)
      disk_type         = lookup(additional_disks.value, "disk_type", null)
      labels            = lookup(addintonal_disks.value, "disk_labels", null)
      kms_key_self_link = var.cmek_key
    }
  }

  dynamic "service_account" {
    for_each = var.service_account == null ? [] : [var.service_account]
    content {
      email  = lookup(service_account.value, "email", null)
      scopes = lookup(service_account.value, "scopes", null)
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
