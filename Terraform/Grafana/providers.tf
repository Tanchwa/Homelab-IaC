terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.18.0"
    }
  }
}

provider "grafana" {
  url  = "http://grafana.andrewsutliff.com/"
  auth = var.grafana_service_account_token
}
