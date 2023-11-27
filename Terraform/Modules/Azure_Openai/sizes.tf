locals {
  scale = var.deployment_size == "Standard" ? {
    instance_type = "Standard",
    tier          = "Standard",
    sku_size      = "S",
    family        = null //may be deployed later
    } : var.deployment_size == "Premium" ? {
    instance_type = "Premium",
    tier          = "",
    sku_size      = "",
    family        = null //may be deployed later
    } : var.deployment_size == "Free" ? {
    instance_type = "Free",
    tier          = "Free",
    sku_size      = "F",
    family        = null //may be deployed later, see https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_deployment#scale
  } : null
}

