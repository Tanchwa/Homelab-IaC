variable "proxmox_node_name" {
  description = "The name of the Proxmox node to deploy the VM on"
  type        = string
}

variable "ubuntu" {
  type = object({
    #image_version = string
    node_name = string
    vm_id     = number
  })
}

variable "vm_password" {
  description = "The password for the VM"
  type        = string
  sensitive   = true
}
