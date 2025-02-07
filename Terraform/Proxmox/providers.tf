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

provider "proxmox" {
  endpoint  = "https://172.31.0.200:8006/"
  username  = "root@pam" #"terraform@proxmox"
  password  = var.ssh_password
  api_token = var.proxmox_api_token
  insecure  = true

  ssh {
    agent       = false
    private_key = file(var.ssh_private_key_path)
    username    = "root"
  }
}
