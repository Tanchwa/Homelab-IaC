resource "azurerm_cognitive_account" "main" {
  name                = var.cog_account_name
  location            = var.location
  resource_group_name = var.resource_group
  kind                = var.cog_service_kind

  sku_name = "S0"

  public_network_access_enabled = var.private_networking.enabled ? false : true //reverses private network logic

  custom_subdomain_name = var.cog_account_name

  dynamic "network_acls" {
    for_each = try(var.private_networking.enabled, true) ? [var.private_networking.enabled] : []

    content {
      default_action = "Deny"
      ip_rules       = null
      virtual_network_rules {
        subnet_id                            = network_acls.value.subnet_id
        ignore_missing_vnet_service_endpoint = true // I'm so glad they implemented this, this really helps with the chicken and egg issue for PE's
      }
    }
  }

  tags = var.tags
}


resource "azurerm_cognitive_deployment" "main" {
  name                 = var.cog_deployment.name
  cognitive_account_id = azurerm_cognitive_account.main.id
  model {
    format  = var.cog_deployment.model.format
    name    = var.cog_deployment.model.model_name
    version = var.cog_deployment.model.version
  }

  scale {
    type     = local.scale.instance_type
    tier     = local.scale.tier
    size     = local.scale.sku_size
    family   = local.scale.family
    capacity = var.tokens_per_minute
  }

}
