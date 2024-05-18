variable "proxmox_api_token" {
  type        = string
  description = "Proxmox API token"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Path to the SSH private key"
}

variable "ssh_password" {
  type        = string
  description = "Password for SSH User"
  sensitive   = true
}
