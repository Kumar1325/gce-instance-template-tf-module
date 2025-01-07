package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestSimpleVM(t *testing.T) {
	t := terraform.InitAndApplyAndDestroy(t, &terraform.Options{
		TerraformDir: "../examples/simple-vm",
	})
	output := terraform.Output(t, t, "name")
	assert.Contains(t, output, "simple-vm-template")
}

func TestConfidentialVM(t *testing.T) {
	t := terraform.InitAndApplyAndDestroy(t, &terraform.Options{
		TerraformDir: "../examples/confidential-vm",
	})
	output := terraform.Output(t, t, "name")
	assert.Contains(t, output, "confidential-vm-template")
}

func TestShieldedVM(t *testing.T) {
	t := terraform.InitAndApplyAndDestroy(t, &terraform.Options{
		TerraformDir: "../examples/shielded-vm",
	})
	output := terraform.Output(t, t, "name")
	assert.Contains(t, output, "shielded-vm-template")
}

func TestSoleTenancyVM(t *testing.T) {
	t := terraform.InitAndApplyAndDestroy(t, &terraform.Options{
		TerraformDir: "../examples/sole-tenancy-vm",
	})
	output := terraform.Output(t, t, "name")
	assert.Contains(t, output, "sole-tenancy-vm-template")
}

func TestAdvancedVM(t *testing.T) {
	t := terraform.InitAndApplyAndDestroy(t, &terraform.Options{
		TerraformDir: "../examples/advanced-vm",
	})
	output := terraform.Output(t, t, "name")
	assert.Contains(t, output, "advanced-vm-template")
}
