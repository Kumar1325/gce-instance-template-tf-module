variable "name_prefix" {
  description = "Name prefix for the instance template"
  type        = string
  default     = "gce-vm-tpl"
}

variable "machine_type" {
  description = "Machine type for the VM"
  type        = string
  validation {
    condition = var.enable_confidential_vm ? contains(
      [
        "n2d",
        "c2d",
        "c3d"
      ],
      split("-", var.machine_type)[0]
    ) : var.machine_type
    error_message = "Only N2D, C2D, and C3D machine types are supported for Confidential VMs."
  }
}

variable "region" {
  description = "Region where the instance will be deployed. Allowed values: US-CENTRAL1, US-EAST4, US-WEST3"
  type        = string
  default     = "us-central1"
  validation {
    condition     = contains(["us-central1", "us-east4", "us-west3"], lower(var.region))
    error_message = "Invalid region specified. Allowed values are: US-CENTRAL1, US-EAST4, US-WEST3 (case-insensitive)."
  }
}

variable "description" {
  description = "Description of the instance template"
  type        = string
  default     = null
}

variable "on_host_maintenance" {
  description = "Maintenance behavior"
  type        = string
  default     = "MIGRATE"
}

variable "automatic_restart" {
  description = "Automatic restart for the VM"
  type        = bool
  default     = true
}

variable "preemptible" {
  description = "Set the VM as preemptible"
  type        = bool
  default     = false
}

variable "spot" {
  type        = bool
  description = "Provision a SPOT instance"
  default     = false
}

variable "spot_instance_termination_action" {
  description = "Action to take when Compute Engine preempts a Spot VM."
  type        = string
  default     = "STOP"

  validation {
    condition     = contains(["STOP", "DELETE"], var.spot_instance_termination_action)
    error_message = "Allowed values for spot_instance_termination_action are: \"STOP\" or \"DELETE\"."
  }
}

variable "min_cpu_platform" {
  description = "Specifies a minimum CPU platform. Applicable values are the friendly names of CPU platforms, such as Intel Haswell or Intel Skylake. See the complete list: https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform"
  type        = string
  default     = null
}

variable "enable_sole_tenancy" {
  description = "Enable sole tenancy for the instance"
  type        = bool
  default     = false
}

variable "sole_tenancy_key" {
  description = "Key for sole tenancy"
  type        = string
  default     = null
}

variable "sole_tenancy_operator" {
  description = "Operator for sole tenancy affinity rule"
  type        = string
  default     = null
}

variable "sole_tenancy_values" {
  description = "Values for sole tenancy affinity rule"
  type        = list(string)
  default     = []
}

variable "tags" {
  type        = list(string)
  description = "Network tags, provided as a list"
  default     = []
}

variable "labels" {
  type        = map(string)
  description = "Labels for the GCE VM instance, provided as a map"
  default     = {}
}

#######
# disk
#######
variable "source_image" {
  description = "Source disk image. If neither source_image nor source_image_family is specified, defaults to the latest public RHEL 8 optimized for GCP image."
  type        = string
  default     = ""
}

variable "source_image_family" {
  description = "Source image family. If neither source_image nor source_image_family is specified, defaults to the latest public RHEL 8 optimized for GCP image."
  type        = string
  default     = "rhel-8"
}

variable "source_image_project" {
  description = "Project where the source image comes from. The default project contains RHEL8 Linux images."
  type        = string
  default     = "rhel-cloud"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = string
  default     = "20"
}

variable "disk_type" {
  description = "GCE disk type. Such as pd-ssd, local-ssd, pd-balanced or pd-standard, pd-ssd, pd-extreme, hyperdisk-balanced, hyperdisk-throughput or hyperdisk-extreme."
  type        = string
  default     = "pd-balanced"
}

variable "disk_labels" {
  description = "Labels to be assigned to boot disk, provided as a map"
  type        = map(string)
  default     = {}
}

variable "disk_encryption_key" {
  description = "The id of the encryption key that is stored in Google Cloud KMS to use to encrypt all the disks on this instance"
  type        = string
}

variable "additional_disks" {
  description = "List of maps of additional disks. See https://www.terraform.io/docs/providers/google/r/compute_instance_template#disk_name"
  type = list(object({
    auto_delete     = optional(bool, true)
    boot            = optional(bool, false)
    device_name     = optional(string)
    disk_name       = optional(string)
    disk_size_gb    = optional(number)
    disk_type       = optional(string)
    disk_labels     = optional(map(string), {})
    interface       = optional(string)
    mode            = optional(string)
    source          = optional(string)
    source_image    = optional(string)
    source_snapshot = optional(string)
  }))
  default = []
}

####################
# network_interface
####################
variable "network" {
  description = "The name or self_link of the network to attach this interface to."
  type        = string
}

variable "subnetwork" {
  description = "The name of the subnetwork to attach this interface to. The subnetwork must exist in the same region this instance will be created in. Either network or subnetwork must be provided."
  type        = string
}

variable "subnetwork_project" {
  description = "The ID of the project in which the subnetwork belongs. If it is not provided, the provider project is used."
  type        = string
  default     = ""
}

variable "nic_type" {
  description = "Valid values are \"VIRTIO_NET\", \"GVNIC\" or set to null to accept API default behavior."
  type        = string
  default     = null

  validation {
    condition     = var.nic_type == null || var.nic_type == "GVNIC" || var.nic_type == "VIRTIO_NET"
    error_message = "The \"nic_type\" variable must be set to \"VIRTIO_NET\", \"GVNIC\", or null to allow API default selection."
  }
}

variable "stack_type" {
  description = "The stack type for this network interface to identify whether the IPv6 feature is enabled or not. Values are `IPV4_IPV6` or `IPV4_ONLY`. Default behavior is equivalent to IPV4_ONLY."
  type        = string
  default     = null
}

###########
# metadata
###########

variable "startup_script" {
  description = "User startup script to run when instances spin up"
  type        = string
  default     = ""
}

variable "metadata" {
  type        = map(string)
  description = "Metadata, provided as a map"
  default     = {}
}

##################
# service_account
##################

variable "service_account" {
  type = object({
    email  = string
    scopes = optional(set(string), ["cloud-platform"])
  })
  description = "Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template#service_account."
}

###########################
# Shielded VMs
###########################
variable "enable_shielded_vm" {
  type        = bool
  default     = false
  description = "Whether to enable the Shielded VM configuration on the instance. Note that the instance image must support Shielded VMs. See https://cloud.google.com/compute/docs/images"
}

variable "shielded_instance_config" {
  description = "Not used unless enable_shielded_vm is true. Shielded VM configuration for the instance."
  type = object({
    enable_secure_boot          = bool
    enable_vtpm                 = bool
    enable_integrity_monitoring = bool
  })

  default = {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
}

###########################
# Confidential Compute VMs
###########################
variable "enable_confidential_vm" {
  type        = bool
  default     = false
  description = "Whether to enable the Confidential VM configuration on the instance. Note that the instance image must support Confidential VMs. See https://cloud.google.com/compute/docs/images"
}

variable "confidential_instance_type" {
  type        = string
  default     = null
  description = "Defines the confidential computing technology the instance uses. If this is set to \"SEV_SNP\", var.min_cpu_platform will be automatically set to \"AMD Milan\". See https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance#confidential_instance_type."

  validation {
    condition     = contains(["SEV", "SEV_SNP", "TDX"], var.confidential_instance_type)
    error_message = "Allowed values for confidential_instance_type are: \"SEV\" \"SEV_SNP\" or \"TDX\"."
  }
}
