variable "proxmox_node_name" {
  description = "The name of the Proxmox node to deploy the VM on"
  type        = string
}

variable "talos" {
  type = object({
    vm_type       = string
    image_version = string
    node_name     = string
    vm_id         = number
  })
  validation {
    condition     = startswith(var.talos.image_version, "v")
    error_message = "The image version must start with 'v'"
  }
  validation {
    condition     = var.talos.vm_type == lower("worker") || var.talos.vm_type == lower("controlplane")
    error_message = "The VM type must be either 'worker' or 'controlplane'"
  }
}
