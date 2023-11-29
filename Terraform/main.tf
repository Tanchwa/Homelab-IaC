resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = "East US"
}


module "azure_openai" {
  source = "./Modules/Azure_Openai"

  resource_group = azurerm_resource_group.main.name
  location       = azurerm_resource_group.main.location

  cog_service_kind = "OpenAI"
  cog_account_name = "tanchwa-test-openai"
  cog_deployment = {
    name = "tanchwa-test-deployment"
    model = {
      format     = "OpenAI"
      model_name = "text-embedding-ada-002"
      version    = "2"
    }
  }

  tokens_per_minute = 750
  deployment_size   = "Standard"

  private_networking = {
    enabled       = false
    subnet_id     = null
    dns_zone_id   = null
    dns_zone_name = null
  }
}


