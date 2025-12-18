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

variable "ubuntu_password" {
  type        = string
  description = "Password for Ubuntu User"
  sensitive   = true
}
