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