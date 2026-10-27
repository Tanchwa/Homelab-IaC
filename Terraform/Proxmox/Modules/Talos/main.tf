# Talos has no SSH/cloud-init login of its own - all configuration happens via
# the Talos API (talos_machine_configuration_apply in the root module), so
# unlike the Ubuntu module there is no `initialization`/user_account block here.

resource "proxmox_virtual_environment_vm" "talos_controlplane_vm" {
  count = var.talos.vm_type == lower("controlplane") ? 1 : 0

  name          = var.talos.node_name
  description   = "Managed by Terraform"
  tags          = ["terraform", "talos", "controlplane"]
  scsi_hardware = "virtio-scsi-single"
  bios          = "ovmf"
  machine       = "q35"

  node_name = var.proxmox_node_name
  vm_id     = var.talos.vm_id

  agent {
    enabled = true
    timeout = "15m"
  }

  startup {
    order      = "4"
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores   = var.talos.cpu_cores
    sockets = 1
    type    = "host"
    flags   = ["+aes"]
  }

  memory {
    dedicated = var.talos.memory_mb
  }

  # Boots the hybrid-bootable Talos ISO directly as this disk's initial content
  # (cloned via file_id, then resized up to disk_size_gb) - no separate cdrom
  # device or boot_order override needed. Talos's installer then overwrites
  # this same disk in place once it has its machine config.
  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    file_id      = var.iso_file_id
    size         = var.talos.disk_size_gb
    file_format  = "raw"
  }

  # Longhorn v2 (block) data engine disk - a thin-provisioned virtual disk on
  # the dedicated "longhorn-thin" LVM-thin datastore (not local-lvm). Left out
  # of every node-config/*.yaml Talos machine-config patch entirely: Talos
  # only touches disks it's told to manage, so this stays a clean, unformatted
  # block device at /dev/sdX - exactly what Longhorn's v2 engine wants to
  # register as a block disk itself.
  disk {
    datastore_id = "longhorn-thin"
    interface    = "scsi1"
    size         = var.talos.longhorn_disk_size_gb
    file_format  = "raw"
    discard      = "on"
    ssd          = true
    iothread     = true
    backup       = false
  }


  network_device {
    bridge      = "vmbr0"
    mac_address = var.lan_mac
  }

  # Direct, physical-LAN-bypassing path to the other Talos nodes and pfSense -
  # see ../../network.tf. No DHCP reservation config here; that's done
  # pfSense-side (Ansible) using this same fixed MAC.
  network_device {
    bridge      = "vmbr2"
    mac_address = var.internal_mac
  }

  operating_system {
    type = "l26"
  }

  tpm_state {
    version = "v2.0"
  }

  efi_disk {
    datastore_id = "local-lvm"
    file_format  = "raw"
    type         = "4m"
  }

  serial_device {}
}

resource "proxmox_virtual_environment_vm" "talos_worker_vm" {
  count = var.talos.vm_type == lower("worker") ? 1 : 0

  name          = var.talos.node_name
  description   = "Managed by Terraform"
  tags          = ["terraform", "talos", "worker"]
  scsi_hardware = "virtio-scsi-single"
  bios          = "ovmf"
  machine       = "q35"

  node_name = var.proxmox_node_name
  vm_id     = var.talos.vm_id

  agent {
    enabled = true
    timeout = "15m"
  }

  startup {
    order      = "4"
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores   = var.talos.cpu_cores
    sockets = 1
    type    = "host"
    flags   = ["+aes"]
  }

  memory {
    dedicated = var.talos.memory_mb
  }

  # Boots the hybrid-bootable Talos ISO directly as this disk's initial content
  # (cloned via file_id, then resized up to disk_size_gb) - no separate cdrom
  # device or boot_order override needed. Talos's installer then overwrites
  # this same disk in place once it has its machine config.
  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    file_id      = var.iso_file_id
    size         = var.talos.disk_size_gb
    file_format  = "raw"
  }

  # Longhorn v2 (block) data engine disk - a thin-provisioned virtual disk on
  # the dedicated "longhorn-thin" LVM-thin datastore (not local-lvm). Left out
  # of every node-config/*.yaml Talos machine-config patch entirely: Talos
  # only touches disks it's told to manage, so this stays a clean, unformatted
  # block device at /dev/sdX - exactly what Longhorn's v2 engine wants to
  # register as a block disk itself.
  disk {
    datastore_id = "longhorn-thin"
    interface    = "scsi1"
    size         = var.talos.longhorn_disk_size_gb
    file_format  = "raw"
    discard      = "on"
    ssd          = true
    iothread     = true
    backup       = false
  }


  network_device {
    bridge      = "vmbr0"
    mac_address = var.lan_mac
  }

  # Direct, physical-LAN-bypassing path to the other Talos nodes and pfSense -
  # see ../../network.tf. No DHCP reservation config here; that's done
  # pfSense-side (Ansible) using this same fixed MAC.
  network_device {
    bridge      = "vmbr2"
    mac_address = var.internal_mac
  }

  operating_system {
    type = "l26"
  }

  tpm_state {
    version = "v2.0"
  }

  efi_disk {
    datastore_id = "local-lvm"
    file_format  = "raw"
    type         = "4m"
  }

  serial_device {}
}
