terraform {
  required_version = "~> 1.8.0"
  #backend "azurerm" {
  #  #backend set during terraform init
  #}

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.54.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.0"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://172.31.0.200:8006/"
  api_token = var.proxmox_api_token
  insecure  = true
}
