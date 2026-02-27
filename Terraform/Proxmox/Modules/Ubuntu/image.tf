resource "proxmox_virtual_environment_download_file" "latest_ubuntu_24_jammy_qcow2_img" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.proxmox_node_name
  url          = "https://releases.ubuntu.com/24.04/ubuntu-24.04.4-live-server-amd64.iso"
}
