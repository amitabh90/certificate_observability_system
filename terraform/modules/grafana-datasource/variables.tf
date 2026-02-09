variable "org_id" {
  type        = number
  description = "Grafana org ID (optional)."
  default     = null
}

variable "name" {
  type        = string
  description = "Datasource name."
}

variable "type" {
  type        = string
  description = "Datasource type (e.g., prometheus, loki, influxdb, elasticsearch)."
  default     = "prometheus"

  validation {
    condition = contains([
      "prometheus", "loki", "influxdb", "elasticsearch",
      "cloudwatch", "grafana", "mysql", "postgres",
      "testdata", "graphite", "opentsdb", "mixed"
    ], var.type)
    error_message = "The datasource type must be a valid Grafana data source type."
  }
}

variable "url" {
  type        = string
  description = "Datasource URL (e.g., http://prometheus:9090)."
}

variable "access_mode" {
  type        = string
  description = "Datasource access mode. Common values: proxy or direct."
  default     = "proxy"

  validation {
    condition     = contains(["proxy", "direct"], var.access_mode)
    error_message = "The access_mode must be either 'proxy' or 'direct'."
  }
}

variable "is_default" {
  type        = bool
  description = "Whether this datasource is the default."
  default     = true
}

variable "basic_auth_enabled" {
  type        = bool
  description = "Enable basic auth to reach the datasource."
  default     = false
}

variable "basic_auth_username" {
  type        = string
  description = "Basic auth username (if enabled)."
  default     = null
}

variable "json_data" {
  type        = map(any)
  description = "Non-sensitive JSON settings for the datasource."
  default     = {}

  validation {
    condition     = can(jsonencode(var.json_data))
    error_message = "The json_data must be a valid JSON-encodable map."
  }
}

variable "secure_json_data" {
  type        = map(string)
  description = "Sensitive JSON settings for the datasource (passwords/tokens)."
  default     = {}
  sensitive   = true

  validation {
    condition     = can(jsonencode(var.secure_json_data))
    error_message = "The secure_json_data must be a valid JSON-encodable map."
  }
}
