terraform {
  required_version = "~> 1.6"
  backend "azurerm" {
    #backend set durring terraform init
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.6"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}



