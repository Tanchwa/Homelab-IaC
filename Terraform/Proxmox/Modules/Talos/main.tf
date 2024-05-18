resource "proxmox_virtual_environment_vm" "talos_controlplane_vm" {
  count = var.talos.vm_type == lower("controlplane") ? 1 : 0

  name        = var.talos.node_name
  description = "Managed by Terraform"
  tags        = ["terraform", "talos"]

  node_name = var.proxmox_node_name
  vm_id     = var.talos.vm_id

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = false
  }

  startup {
    order      = "4"
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores   = 4
    sockets = 1
    type    = "host"
    flags   = ["+aes"]
  }

  memory {
    dedicated = 4000
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.talos_img.id
    interface    = "scsi0"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [trimspace(tls_private_key.talos_vm_key.public_key_openssh)]
      password = random_password.talos_vm_password.result
      username = "talos"
    }

    #user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  tpm_state {
    version = "v2.0"
  }

  serial_device {}
}

resource "proxmox_virtual_environment_vm" "talos_worker_vm" {
  count = var.talos.vm_type == lower("worker") ? 1 : 0

  name        = var.talos.node_name
  description = "Managed by Terraform"
  tags        = ["terraform", "talos"]

  node_name = var.proxmox_node_name
  vm_id     = var.talos.vm_id

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = false
  }

  startup {
    order      = "4"
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
    flags   = ["+aes"]
  }

  memory {
    dedicated = 4000
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.talos_img.id
    interface    = "scsi0"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [trimspace(tls_private_key.talos_vm_key.public_key_openssh)]
      password = random_password.talos_vm_password.result
      username = "talos"
    }

    #user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  tpm_state {
    version = "v2.0"
  }

  serial_device {}
}

resource "random_password" "talos_vm_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "talos_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "talos_vm_password" {
  value     = random_password.talos_vm_password.result
  sensitive = true
}

output "talos_vm_private_key" {
  value     = tls_private_key.talos_vm_key.private_key_pem
  sensitive = true
}

output "talos_vm_public_key" {
  value = tls_private_key.talos_vm_key.public_key_openssh
}
