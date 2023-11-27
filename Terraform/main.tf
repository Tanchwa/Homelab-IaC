resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = "East US"
}


module "azure_openai" {
  source = "./Modules/Azure_Openai"

  resource_group = azurerm_resource_group.main.name
  location       = azurerm_resource_group.main.location

  cog_service_kind = "OpenAI"
  cog_account_name = "Tanchwa_Test_OpenAI"
  cog_deployment = {
    name = "Tanchwa_Test_Deployment"
  }

  tokens_per_minute = 100
  deployment_size   = "Standard"

  private_networking = {
    enabled   = false
    subnet_id = null
  }
}


