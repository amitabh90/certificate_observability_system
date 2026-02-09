output "datasource_id" {
  value       = grafana_data_source.this.id
  description = "Grafana datasource ID."
}

output "datasource_uid" {
  value       = grafana_data_source.this.uid
  description = "Grafana datasource UID."
}

output "datasource_name" {
  value       = grafana_data_source.this.name
  description = "Grafana datasource name."
}

output "datasource_type" {
  value       = grafana_data_source.this.type
  description = "Grafana datasource type."
}

output "datasource_url" {
  value       = grafana_data_source.this.url
  description = "Grafana datasource URL."
}
