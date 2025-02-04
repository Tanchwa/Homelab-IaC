variable "grafana_service_account_token" {
  description = "The token for the Grafana service account"
  type        = string
  sensitive   = true
}

variable "line_jwt" {
  description = "Web Token for Authenticating to Grafana Notifications Channel"
  type        = string
  sensitive   = true
}
