variable "proxmox_api_token" {
  type        = string
  description = "Proxmox API token"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Path to the SSH private key"
  default     = "~/.ssh/id_rsa"
}

variable "ssh_password" {
  type        = string
  description = "Password for SSH User"
  sensitive   = true
}

#variable "ubuntu_password" {
#  type        = string
#  description = "Password for Ubuntu User"
#  sensitive   = true
#}

# ─── Talos cluster ───────────────────────────────────────────────────────────

variable "cluster_name" {
  description = "Name of the Talos/Kubernetes cluster."
  type        = string
  default     = "homelab"
}

variable "talos_version" {
  description = "Talos version to build and install. Must start with 'v'."
  type        = string
  default     = "v1.9.5"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the Talos cluster. Must be a full patch version (e.g. v1.32.3)."
  type        = string
  default     = "v1.32.3"
}

variable "cilium_version" {
  description = "Cilium Helm chart version to install."
  type        = string
  default     = "1.17.3"
}
