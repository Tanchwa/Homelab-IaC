variable "proxmox_node_name" {
  description = "The Name of the Desired Proxmox Node for VM Placement"
  type        = string
}

variable "home_assistant" {
  description = "Home Assistant VM Configuration"
  type = object({
    vm_id         = number
    image_version = string
  })
}

variable "ssh_private_key_path" {
  description = "The Path to the SSH Private Key for Proxmox"
  type        = string
}

variable "ssh_password" {
  description = "The Password for the SSH Private Key for Proxmox"
  type        = string
  sensitive   = true
} //only used for remote exec task that is now commented out
