resource "google_compute_instance_template" "default" {
  name_prefix        = var.name
  machine_type       = var.machine_type
  region             = var.region
  can_ip_forward     = false
  description        = var.description

  dynamic "confidential_instance_config" {
    for_each = var.enable_confidential_vm ? [1] : []
    content {
      enable_confidential_compute = true
    }
  }

  shielded_instance_config {
    enable_secure_boot          = var.shielded_secure_boot
    enable_vtpm                 = var.shielded_vtpm
    enable_integrity_monitoring = var.shielded_integrity_monitoring
  }

  scheduling {
    on_host_maintenance = var.on_host_maintenance
    automatic_restart   = var.automatic_restart
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
    source_image      = var.source_image
    disk_size_gb      = var.disk_size
    disk_type         = var.disk_type
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
      kms_key_self_link = var.cmek_key
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}
