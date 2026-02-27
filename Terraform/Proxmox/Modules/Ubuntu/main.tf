resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "cloudinit"
  datastore_id = "local"
  node_name    = var.proxmox_node_name

  source_file {
    path = "${path.module}/cloudinit.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name        = var.ubuntu.node_name
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu"]

  node_name = var.proxmox_node_name
  vm_id     = var.ubuntu.vm_id

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = false
  }
  # if agent is not enabled, the VM may not be able to shutdown properly, and may need to be forced off
  stop_on_destroy = true

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores   = 6
    sockets = 2
    type    = "host"
    flags   = ["+aes"]
  }

  memory {
    dedicated = var.ubuntu.memory_size
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.latest_ubuntu_24_jammy_qcow2_img.id
    interface    = "scsi0"
    size         = var.ubuntu.disk_size
  }

  initialization {
    ip_config {
      ipv4 {
        address = "172.31.0.40/17"
        gateway = "172.31.0.1"
      }
    }

    user_account {
      keys     = [trimspace(file(var.ubuntu.ssh_public_key_path))]
      password = var.vm_password
      username = "asutliff"
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

  lifecycle {
    ignore_changes = [disk[0].file_id]
  }
}
