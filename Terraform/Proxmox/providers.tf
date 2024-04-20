terraform {
  required_version = "value"
  backend "azurerm" {
    #backend set during terraform init
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 1.0"
    }
  }
}

provider "proxmox" {
  pm_api_url      = var.pm_api_url
  pm_user         = var.pm_user
  pm_password     = var.pm_password
  pm_tls_insecure = true
}
