terraform {
  required_version = "~> 1.16.0"
  #backend "azurerm" {
  #  #backend set during terraform init
  #}

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.57.0"
    }
  }
}
