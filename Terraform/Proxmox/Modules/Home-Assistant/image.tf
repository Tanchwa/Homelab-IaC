/*resource "proxmox_virtual_environment_file" "home_assistant_img" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "proxmox"

  source_file {
    path = "/home/terraform/images/haos_generic-x86-12.2.img"
  }
}*/

resource "proxmox_virtual_environment_download_file" "home_assistant_img" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "proxmox"
  url          = "https://github.com/home-assistant/operating-system/releases/download/12.2/haos_ova-12.2.qcow2.xz"
  file_name    = "haos_generic-x86-12.2.img"
}
