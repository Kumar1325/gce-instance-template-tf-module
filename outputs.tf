output "name" {
  description = "Instance Template name"
  value = google_compute_instance_template.tpl.name
}

output "id" {
  description = "An identifier for the resource with format projects/{{project}}/global/instanceTemplates/{{name}}"
  value = google_compute_instance_template.tpl.id
}

output "self_link" {
  description = "The URI of the created resource."
  value = google_compute_instance_template.tpl.self_link
}
