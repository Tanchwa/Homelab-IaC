terraform {
  required_version = "~> 1.10.0"
  #backend "azurerm" {
  #  #backend set during terraform init
  #}

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.57.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}
