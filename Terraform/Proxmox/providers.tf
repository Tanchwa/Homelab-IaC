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
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.7"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.4"
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

provider "talos" {}

# ─── Kubeconfig retrieval ─────────────────────────────────────────────────────
# Reads from talos_cluster_kubeconfig in talos.tf, created after the cluster is
# bootstrapped. On a first apply, Terraform resolves talos.tf's resources
# before these providers are used, so a single `terraform apply` is enough.
locals {
  _cluster_kube = yamldecode(talos_cluster_kubeconfig.this.kubeconfig_raw)
}

provider "helm" {
  kubernetes {
    host                   = local._cluster_kube.clusters[0].cluster.server
    cluster_ca_certificate = base64decode(local._cluster_kube.clusters[0].cluster["certificate-authority-data"])
    client_certificate     = base64decode(local._cluster_kube.users[0].user["client-certificate-data"])
    client_key             = base64decode(local._cluster_kube.users[0].user["client-key-data"])
  }
}

provider "kubernetes" {
  host                   = local._cluster_kube.clusters[0].cluster.server
  cluster_ca_certificate = base64decode(local._cluster_kube.clusters[0].cluster["certificate-authority-data"])
  client_certificate     = base64decode(local._cluster_kube.users[0].user["client-certificate-data"])
  client_key             = base64decode(local._cluster_kube.users[0].user["client-key-data"])

}
