output "ha_info" {
  value     = module.home_assistant.ha_vm
  sensitive = true
}
