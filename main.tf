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

resource "google_compute_instance_template" "tpl" {
  name_prefix             = var.name_prefix
  machine_type            = var.machine_type
  region                  = var.region
  can_ip_forward          = false
  description             = var.description
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
    dynamic "node_affinities" {
      for_each = var.enable_sole_tenancy ? [1] : []
      content {
        key      = "compute.googleapis.com/node-group-name"
        operator = var.sole_tenancy_operator
        values   = var.sole_tenancy_values
      }
    }
  }

  disk {
    auto_delete       = true
    boot              = true
    source_image      = local.source_image
    disk_size_gb      = var.disk_size_gb
    disk_type         = var.disk_type
    labels            = var.disk_labels
    disk_encryption_key {
      kms_key_self_link = var.disk_encryption_key
    }
  }

  dynamic "disk" {
    for_each = var.additional_disks
    content {
      auto_delete       = lookup(disk.value, "auto_delete", true)
      boot              = false
      device_name       = lookup(disk.value, "device_name", null)
      disk_name         = lookup(disk.value, "disk_name", null)
      disk_size_gb      = lookup(disk.value, "disk_size_gb", lookup(disk.value, "disk_type", null) == "local-ssd" ? "375" : 100)
      disk_type         = lookup(disk.value, "disk_type", "pd-standard")
      interface         = lookup(disk.value, "interface", lookup(disk.value, "disk_type", null) != "local-ssd" ? "SCSI" : null)
      mode              = lookup(disk.value, "mode", null)
      source            = lookup(disk.value, "source", null)
      source_image      = lookup(disk.value, "source_image", null)
      source_snapshot   = lookup(disk.value, "source_snapshot", null)
      type              = lookup(disk.value, "disk_type", null) == "local-ssd" ? "SCRATCH" : "PERSISTENT"
      labels            = lookup(disk.value, "disk_labels", null)
      disk_encryption_key {
        kms_key_self_link = var.disk_encryption_key
      }
    }
  }

  dynamic "service_account" {
    for_each = var.service_account == null ? [] : [var.service_account]
    content {
      email  = lookup(service_account.value, "email", null)
      scopes = lookup(service_account.value, "scopes", null)
    }
  }

  network_interface {
    network            = var.network
    subnetwork         = var.subnetwork
    subnetwork_project = var.subnetwork_project
    nic_type           = var.nic_type
    stack_type         = var.stack_type
  }

  lifecycle {
    create_before_destroy = true
  }
}
