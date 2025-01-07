variable "name_prefix" {
  description = "Name prefix of the instance template"
  type        = string
}

variable "machine_type" {
  description = "Machine type for the VM"
  type        = string
  validation {
    condition     = var.enable_confidential_vm ? contains(["n2d-standard", "n2d-highmem"], var.machine_type) : true
    error_message = "Confidential VMs require an AMD-based machine type (n2d)."
  }
}

variable "region" {
  description = "Region for the instance template"
  type        = string
}

variable "description" {
  description = "Description of the instance template"
  type        = string
  default     = null
}

variable "enable_confidential_vm" {
  description = "Enable confidential VM"
  type        = bool
  default     = false
}

variable "shielded_secure_boot" {
  description = "Enable secure boot for Shielded VM"
  type        = bool
  default     = false
}

variable "shielded_vtpm" {
  description = "Enable vTPM for Shielded VM"
  type        = bool
  default     = false
}

variable "shielded_integrity_monitoring" {
  description = "Enable integrity monitoring for Shielded VM"
  type        = bool
  default     = false
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

variable "source_image" {
  description = "Source image for the VM"
  type        = string
}

variable "disk_size" {
  description = "Disk size for the VM"
  type        = number
  default     = 10
}

variable "disk_type" {
  description = "Disk type for the VM (pd-standard, pd-ssd, etc.)"
  type        = string
  default     = "pd-standard"
}

variable "cmek_key" {
  description = "KMS key for CMEK encryption"
  type        = string
  validation {
    condition     = can(regex("projects/.+/locations/.+/keyRings/.+/cryptoKeys/.+", var.cmek_key))
    error_message = "Provide a valid CMEK key in the format projects/{project}/locations/{location}/keyRings/{keyRing}/cryptoKeys/{key}."
  }
}

variable "additional_disks" {
  description = "Additional disks for the VM"
  type        = list(object({
    auto_delete = optional(bool)
    source_image = optional(string)
    disk_size = optional(number)
    disk_type = optional(string)
  }))
  default = []
}
