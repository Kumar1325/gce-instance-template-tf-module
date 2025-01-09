output "self_link" {
  description = "Self-link to the instance template"
  value       = module.shielded_vm.self_link
}

output "name" {
  description = "Name of the instance template"
  value       = module.shielded_vm.name
}

output "id" {
  description = "Name of the instance template"
  value       = module.shielded_vm.id
}