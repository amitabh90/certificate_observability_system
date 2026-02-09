module "prometheus_ds" {
  source = "./modules/grafana-datasource"

  name        = "DS-Prometheus"
  type        = "prometheus"
  url         = "http://prometheus:9090"
  access_mode = "proxy"
  is_default  = true

  # Optional Prometheus datasource settings in Grafana:
  json_data = {
    httpMethod   = "POST"
    timeInterval = "15s"
  }
}
