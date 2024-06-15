resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = "East US"
}


resource "azurerm_resource_group" "secondary" {
  name     = "tanchwa-test-eus2"
  location = "East US 2"
}


module "azure_openai" {
  source = "./Modules/Azure_Openai"

  resource_group = azurerm_resource_group.main.name
  location       = azurerm_resource_group.main.location

  existing_cog_account = false
  cog_service_kind     = "OpenAI"
  cog_account_name     = "tanchwa-test-openai"
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


module "azure_gpt4" {
  source = "./Modules/Azure_Openai"

  resource_group = azurerm_resource_group.secondary.name
  location       = azurerm_resource_group.secondary.location

  existing_cog_account = false
  cog_service_kind     = "OpenAI"
  cog_account_name     = "tanchwa-gpt4"
  cog_deployment = {
    name = "tanchwa-gpt4"
    model = {
      format     = "OpenAI"
      model_name = "gpt-4"
      version    = "1106-Preview"
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

  depends_on = [module.azure_openai]
}
