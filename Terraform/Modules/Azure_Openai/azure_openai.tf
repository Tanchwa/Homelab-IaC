resource "azurerm_cognitive_account" "main" {
  name                = var.cog_account_name
  location            = var.location
  resource_group_name = var.resource_group
  kind                = var.cog_service_kind

  sku_name = "S0"

  tags = var.tags
}


resource "azurerm_cognitive_deployment" "main" {
  name                 = var.cog_deployment.name
  cognitive_account_id = azurerm_cognitive_account.main.id
  model {
    format  = var.cog_deployment.model.format
    name    = var.cog_deployment.model.name
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
