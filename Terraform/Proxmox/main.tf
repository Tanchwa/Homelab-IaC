/*module "home_assistant" {
  source = "./Modules/Home-Assistant"

  proxmox_node_name = "proxmox"
  home_assistant = {
    vm_id = 400
  }

  ssh_private_key_path = var.ssh_private_key_path
  ssh_password         = var.ssh_password
} */

module "talos_controlplane" {
  source = "./Modules/Talos"
  count  = 1

  proxmox_node_name = "proxmox"
  talos = {
    image_version = "v1.7.2"
    vm_type       = "controlplane"
    node_name     = "talos-controlplane${count.index}"
    vm_id         = tonumber(format("20%d", count.index))
  }
}

module "talos_worker" {
  source = "./Modules/Talos"
  count  = 2

  proxmox_node_name = "proxmox"
  talos = {
    image_version = "v1.7.2"
    vm_type       = "worker"
    node_name     = "talos-worker${count.index}"
    vm_id         = tonumber(format("30%d", count.index))
  }
}
