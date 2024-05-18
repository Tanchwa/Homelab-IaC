/* module "home_assistant" {
  source = "./Modules/Home-Assistant"

  proxmox_node_name = "proxmox"
} */

module "talos_controlplane" {
  source = "./Modules/Talos"
  count  = 1

  proxmox_node_name = "proxmox"
  talos = {
    image_version = "v1.7.1"
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
    image_version = "v1.7.1"
    vm_type       = "worker"
    node_name     = "talos-worker${count.index}"
    vm_id         = tonumber(format("30%d", count.index))
  }
}
