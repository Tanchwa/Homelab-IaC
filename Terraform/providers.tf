terraform {
  required_version = "~> 1.6"
  backend "azurerm" {
    #backend set durring terraform init
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.8"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 1.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

provider "proxmox" {}
