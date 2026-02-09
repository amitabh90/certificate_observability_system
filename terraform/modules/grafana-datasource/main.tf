terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = ">= 2.0.0"
    }
  }
}

resource "grafana_data_source" "this" {
  name                = var.name
  type                = var.type
  url                 = var.url
  access_mode         = var.access_mode
  is_default          = var.is_default
  basic_auth_enabled  = var.basic_auth_enabled
  basic_auth_username = var.basic_auth_username

  json_data_encoded        = jsonencode(var.json_data)
  secure_json_data_encoded = jsonencode(var.secure_json_data)

  # Optional (Grafana Cloud / multi-org setups)
  org_id = var.org_id
}
