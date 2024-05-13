module "home_assistant" {
  source = "./Modules/Home-Assistant"

  proxmox_node_name = "proxmox"
}
