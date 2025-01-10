# Terraform GCP Instance Template Module

This Terraform module creates a Google Cloud Platform (GCP) Instance Template with support for advanced features such as Confidential VMs, Shielded VMs, Sole Tenancy, and Customer-Managed Encryption Keys (CMEK). The module offers machine type validation, dynamic blocks, and supports configuring additional VM features like automatic restart, preemptible instances, and spot instances.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Module Inputs](#module-inputs)
- [Module Outputs](#module-outputs)
- [Usage Example](#usage-example)
- [License](#license)

## Prerequisites

Before using this module, you must have:

- A GCP account and a project set up.
- Terraform installed (version 1.x recommended).
- Proper credentials and permissions to create and manage GCP resources.

## Module Inputs

| Input Name                       | Description                                                                                              | Type         | Default Value | Required |
|-----------------------------------|----------------------------------------------------------------------------------------------------------|--------------|---------------|----------|
| `name_prefix`                     | Name prefix for the instance template.                                                                   | `string`     | `gce-vm-tpl`  | no       |
| `machine_type`                    | Machine type for the VM.                                                                                 | `string`     | `"n1-standard-1"` | no    |
| `region`                          | The region where the instance will be deployed. Allowed values: `us-central1`, `us-east4`, `us-west3`.   | `string`     | `"us-central1"` | no    |
| `description`                     | Description of the instance template.                                                                     | `string`     | `null`        | no       |
| `on_host_maintenance`             | Maintenance behavior for the instance.                                                                     | `string`     | `"MIGRATE"`   | no       |
| `automatic_restart`               | Whether the VM should automatically restart on failure.                                                   | `bool`       | `true`        | no       |
| `preemptible`                     | Whether the instance should be preemptible.                                                               | `bool`       | `false`       | no       |
| `spot`                            | Whether to provision a SPOT instance.                                                                     | `bool`       | `false`       | no       |
| `min_cpu_platform`                | Minimum CPU platform for the VM.                                                                         | `string`     | `null`        | no       |
| `enable_sole_tenancy`             | Enable sole tenancy for the instance.                                                                     | `bool`       | `false`       | no       |
| `tags`                            | List of network tags for the instance.                                                                    | `list(string)` | `[]`        | no       |
| `labels`                          | Labels for the instance template, provided as a map.                                                     | `map(string)` | `{}`         | no       |
| `disk_size_gb`                    | Boot disk size in GB.                                                                                   | `string`     | `20`          | no       |
| `disk_type`                       | Disk type for the instance (e.g., `pd-ssd`, `local-ssd`, `pd-balanced`).                                 | `string`     | `pd-balanced` | no       |
| `disk_encryption_key`             | The encryption key ID to encrypt all disks on this instance.                                              | `string`     | `null`        | no       |
| `additional_disks`                | List of additional disks attached to the instance.                                                       | `list(object)` | `[]`         | no       |
| `network`                         | Network to attach the instance to.                                                                        | `string`     | n/a           | yes      |
| `subnetwork`                      | Subnetwork to attach the instance to.                                                                    | `string`     | n/a           | yes      |
| `service_account`                 | Service account to attach to the instance.                                                                | `object`     | n/a           | yes      |
| `enable_shielded_vm`              | Enable Shielded VMs for enhanced security.                                                                | `bool`       | `false`       | no       |
| `shielded_instance_config`        | Shielded VM configuration if `enable_shielded_vm` is set to true.                                         | `object`     | `null`        | no       |
| `enable_confidential_vm`          | Enable Confidential VMs for added security.                                                               | `bool`       | `false`       | no       |
| `confidential_instance_type`      | Type of confidential instance to use (e.g., `SEV`, `TDX`).                                               | `string`     | `null`        | no       |
| `startup_script`                  | User startup script to run when instances spin up.                                                        | `string`     | `""`          | no       |
| `metadata`                        | Metadata for the instance template, provided as a map.                                                   | `map(string)` | `{}`         | no       |

## Module Outputs

| Output Name            | Description                                                                                          |
|------------------------|------------------------------------------------------------------------------------------------------|
| `name`                 | Name of the instance template.                                                                       |
| `id`                   | ID of the instance template.                                                                         |
| `self_link`            | URI of the created instance template.                                                                |
| `self_link_unique`     | Unique URI for the created instance template, which includes a unique ID.                           |

## Usage Example

### Basic Example

```hcl
module "instance_template" {
  source        = "path/to/your/module"
  project_id    = "your-gcp-project-id"
  region        = "us-central1"
  name_prefix   = "my-instance-template"
  machine_type  = "n1-standard-4"
  enable_shielded_vm = true
  enable_confidential_vm = false
  tags          = ["web-server", "production"]
  disk_size_gb  = "50"
  metadata      = {
    "startup-script" = "#!/bin/bash\necho Hello, world!"
  }

  network       = "default"
  subnetwork    = "default"
  service_account = {
    email  = "my-service-account@your-project.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}

output "instance_template_id" {
  value = module.instance_template.id
}
```

### Example with Confidential VMs and Sole Tenancy
```hcl
module "instance_template" {
  source                = "path/to/your/module"
  project_id            = "your-gcp-project-id"
  region                = "us-west3"
  name_prefix           = "secure-instance-template"
  machine_type          = "n2d-standard-8"
  enable_confidential_vm = true
  confidential_instance_type = "SEV_SNP"
  enable_sole_tenancy   = true
  sole_tenancy_key      = "some-key"
  tags                  = ["secure", "confidential"]
  metadata              = {
    "startup-script" = "#!/bin/bash\necho Secure VM!"
  }
  network               = "default"
  subnetwork            = "default"
  service_account       = {
    email  = "my-service-account@your-project.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}
```

## Terratest Example

The module includes a `test.go` Terratest test file in the `tests/` folder. Below is a simplified example of how it validates the advanced configurations:

```go
// Terratest cases for the provided Terraform configuration
package test

import (
	"context"
	"testing"
	"time"

	"cloud.google.com/go/compute/apiv1"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	computepb "google.golang.org/genproto/googleapis/cloud/compute/v1"
)

func TestGCPInstanceTemplate(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../",

		Vars: map[string]interface{}{
			"name_prefix":                "test-vm",
			"machine_type":              "n1-standard-1",
			"region":                    "us-central1",
			"source_image":              "", // Leave empty to test default behavior
			"source_image_family":       "debian-11",
			"source_image_project":      "debian-cloud",
			"enable_shielded_vm":        true,
			"enable_confidential_vm":    true,
			"confidential_instance_type": "SEV_SNP",
			"min_cpu_platform":          "AMD Milan",
			"on_host_maintenance":       "MIGRATE",
			"preemptible":               false,
			"spot":                      false,
			"disk_size_gb":              50,
			"disk_type":                 "pd-balanced",
			"enable_sole_tenancy":       false,
			"shielded_instance_config": map[string]interface{}{
				"enable_secure_boot":          true,
				"enable_vtpm":                 true,
				"enable_integrity_monitoring": true,
			},
			"service_account": map[string]interface{}{
				"email":  "default",
				"scopes": []string{"https://www.googleapis.com/auth/cloud-platform"},
			},
			"network": "default",
			"subnetwork": "default",
			"disk_encryption_key": "projects/your-project-id/locations/global/keyRings/your-keyring/cryptoKeys/your-key",
		},
	}

	// Ensure Terraform init, plan, apply, and destroy lifecycle works
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Fetch the instance template name from Terraform output
	templateName := terraform.Output(t, terraformOptions, "template_id")

	// Validate instance details by calling GCP Compute API
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer cancel()

	computeService, err := compute.NewInstanceTemplatesRESTClient(ctx)
	assert.NoError(t, err, "Failed to create compute client")
	defer computeService.Close()

	project := "your-gcp-project-id" // Replace with your project ID
	region := "us-central1"         // Ensure it matches the test configuration

	template, err := computeService.Get(ctx, &computepb.GetInstanceTemplateRequest{
		Project: project,
		InstanceTemplate: templateName,
	})
	assert.NoError(t, err, "Failed to fetch instance template")

	// Assertions for the instance template configuration
	assert.Equal(t, "n1-standard-1", template.Properties.MachineType, "Machine type should match")
	assert.Equal(t, "AMD Milan", template.Properties.MinCpuPlatform, "Minimum CPU platform should match")
	assert.Equal(t, int32(50), template.Properties.Disks[0].InitializeParams.DiskSizeGb, "Disk size should match")

	// Validate Shielded VM settings
	assert.Equal(t, true, template.Properties.ShieldedInstanceConfig.GetEnableSecureBoot(), "Secure Boot should be enabled")
	assert.Equal(t, true, template.Properties.ShieldedInstanceConfig.GetEnableVtpm(), "vTPM should be enabled")
	assert.Equal(t, true, template.Properties.ShieldedInstanceConfig.GetEnableIntegrityMonitoring(), "Integrity Monitoring should be enabled")

	// Validate Confidential VM settings
	assert.Equal(t, true, template.Properties.ConfidentialInstanceConfig.EnableConfidentialCompute, "Confidential Compute should be enabled")

	// Validate Service Account
	assert.NotNil(t, template.Properties.ServiceAccounts, "Service account should be set")
	assert.Equal(t, "default", template.Properties.ServiceAccounts[0].Email, "Service account email should match")
	assert.Contains(t, template.Properties.ServiceAccounts[0].Scopes, "https://www.googleapis.com/auth/cloud-platform", "Service account scope should include cloud-platform")

	// Validate Disk Encryption with CMEK
	assert.Equal(t, "projects/your-project-id/locations/global/keyRings/your-keyring/cryptoKeys/your-key", template.Properties.Disks[0].DiskEncryptionKey.KmsKeyName, "CMEK encryption key should match")
}
```

---

## Testing Instructions

1. **Run Terraform Plan**:
   ```bash
   terraform plan
   ```

2. **Apply Configuration**:
   ```bash
   terraform apply
   ```

3. **Run Tests**:
   ```bash
   go test -v tests/gce_test.go
   ```

---

## Best Practices

- Use separate environments (e.g., staging, production) for testing.
- Validate variable inputs for correctness.
- Leverage Terratest to automate infrastructure validation.
- Enable GCP monitoring and logging for Shielded and Confidential VMs.
- Ensure CMEK keys are properly managed and have sufficient IAM permissions.

---

## References

- [Google Cloud Platform: Compute Engine Documentation](https://cloud.google.com/compute/docs)
- [Terraform: Google Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
