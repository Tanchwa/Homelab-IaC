resource "proxmox_virtual_environment_vm" "home_assistant_vm" {
  name        = "home-assistant"
  description = "Managed by Terraform"
  tags        = ["terraform", "home-assistant"]

  node_name = var.proxmox_node_name
  vm_id     = 200

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = false
  }

  startup {
    order      = "3"
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
    dedicated = 4295
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.home_assistant_img.id
    interface    = "scsi0"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [trimspace(tls_private_key.ha_vm_key.public_key_openssh)]
      password = random_password.ha_vm_password.result
      username = "home-assistant"
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


resource "random_password" "ha_vm_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "ha_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "ha_vm_password" {
  value     = random_password.ha_vm_password.result
  sensitive = true
}

output "ha_vm_private_key" {
  value     = tls_private_key.ha_vm_key.private_key_pem
  sensitive = true
}

output "ubuntu_vm_public_key" {
  value = tls_private_key.ha_vm_key.public_key_openssh
}
