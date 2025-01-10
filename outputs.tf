output "name" {
  description = "Instance Template name"
  value       = google_compute_instance_template.tpl.name
}

output "id" {
  description = "An identifier for the resource with format projects/{{project}}/global/instanceTemplates/{{name}}"
  value       = google_compute_instance_template.tpl.id
}

output "self_link" {
  description = "The URI of the created resource."
  value       = google_compute_instance_template.tpl.self_link
}

output "self_link_unique" {
  description = "A special URI of the created resource that uniquely identifies this instance template with the following format: projects/{{project}}/global/instanceTemplates/{{name}}?uniqueId={{uniqueId}}"
  value = google_compute_instance_template.tpl.self_link_unique
}