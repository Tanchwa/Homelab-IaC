# Talos node provisioning - 1 controlplane + 2 workers, matching the current
# Ubuntu/kubeadm topology. See talos.tf for cluster bootstrap and cilium.tf for
# CNI install.

module "talos_controlplane" {
  source = "./Modules/Talos"

  proxmox_node_name = "proxmox"
  iso_file_id       = proxmox_virtual_environment_download_file.talos_img.id
  talos = {
    vm_type               = "controlplane"
    image_version         = var.talos_version
    node_name             = "talos-controlplane0"
    vm_id                 = 200
    cpu_cores             = 4
    memory_mb             = 8192
    disk_size_gb          = 40
    longhorn_disk_size_gb = 100
  }
}

module "talos_worker" {
  source = "./Modules/Talos"
  count  = 3

  proxmox_node_name = "proxmox"
  iso_file_id       = proxmox_virtual_environment_download_file.talos_img.id
  talos = {
    vm_type               = "worker"
    image_version         = var.talos_version
    node_name             = "talos-worker${count.index}"
    vm_id                 = 300 + count.index
    cpu_cores             = 4
    memory_mb             = 16384
    disk_size_gb          = 40
    longhorn_disk_size_gb = 150
  }
}
