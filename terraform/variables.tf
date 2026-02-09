variable "grafana_url" {
  type        = string
  description = "Grafana URL (e.g., http://localhost:3000)."
}

variable "grafana_auth" {
  type        = string
  description = "Grafana auth (API token recommended). For local, can be 'admin:admin123'."
  sensitive   = true
}
