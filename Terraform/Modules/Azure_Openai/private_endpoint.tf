resource "azurerm_private_endpoint" "cognative_services" {
  count = var.private_networking.enabled ? 1 : 0

  name                = format("%s-%s", var.cog_account_name, "endpoint")
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.private_networking.subnet_id

  private_service_connection {
    name                           = "example-privateserviceconnection"
    private_connection_resource_id = try(azurerm_cognitive_account.main[1].id, data.azurerm_cognitive_account.existing[1].id)
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = var.private_networking.dns_zone_name
    private_dns_zone_ids = [var.private_networking.dns_zone_id]
  }
}
