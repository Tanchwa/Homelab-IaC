resource "grafana_contact_point" "line" {
  name = "tanchwa_line"

  line {
    token       = var.line_jwt
    description = "Line Notification to Personal Account"
    title       = "Grafana Kubernetes Alert"
  }
}
