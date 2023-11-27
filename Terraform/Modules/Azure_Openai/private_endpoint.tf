resource "azurerm_private_endpoint" "cognative_services" {
  name                = format("%s-%s", var.cog_account_name, "endpoint")
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.private_networking.subnet_id

  private_service_connection {
    name                           = "example-privateserviceconnection"
    private_connection_resource_id = azurerm_cognitive_account.main.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = null
    private_dns_zone_ids = null
  }
}
