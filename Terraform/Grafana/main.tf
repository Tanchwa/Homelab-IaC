resource "grafana_contact_point" "line" {
  name = "tanchwa_line"

  line {
    token       = var.line_jwt
    title       = "Grafana Kubernetes Alert"
    description = "{{ template \"custom.alerts.line\" .}}"
  }
}

resource "grafana_message_template" "line" {
  name = "custom.alerts"

  template = <<EOT
 {{ define "custom.alerts.line" -}}
{{ len .Alerts }} alert(s)
{{ range .Alerts -}}
  {{ template "alert.summary_and_description" . -}}
{{ end -}}
{{ end -}}
{{ define "alert.summary_and_description" }}
  Summary: {{.Annotations.summary}}
  Status: {{ .Status }}
  Description: {{.Annotations.description}}
{{ end -}}
EOT
}
