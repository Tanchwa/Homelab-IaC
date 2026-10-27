variable "proxmox_node_name" {
  description = "The name of the Proxmox node to deploy the VM on"
  type        = string
}

variable "iso_file_id" {
  description = "File ID of the (shared, built once at the root) Talos boot ISO - see ../../image.tf."
  type        = string
}

variable "internal_mac" {
  description = "MAC address for this node's second NIC, on the internal-only vmbr2 bridge (see ../../network.tf). Fixed/deterministic so a DHCP static reservation can be written for it ahead of time."
  type        = string
}

variable "lan_mac" {
  description = "MAC address for this node's primary NIC, on vmbr0 (the physical LAN). Fixed/deterministic - without this Proxmox assigns a random MAC on every VM recreate, which rotates the DHCP-leased address and breaks the Talos/Kubernetes certs and kubeconfig that have the old address baked in."
  type        = string
}

variable "talos" {
  type = object({
    vm_type       = string
    image_version = string
    node_name     = string
    vm_id         = number
    cpu_cores     = optional(number, 2)
    memory_mb     = optional(number, 4000)
    disk_size_gb  = optional(number, 20)
    # Size of the thin-provisioned virtual disk carved out of the Longhorn
    # LVM-thin datastore for the v2 (block) data engine - see main.tf.
    longhorn_disk_size_gb = optional(number, 150)
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
