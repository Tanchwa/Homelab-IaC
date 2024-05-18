resource "proxmox_virtual_environment_download_file" "talos_img" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.proxmox_node_name
  url          = "https://github.com/siderolabs/talos/releases/download/${var.talos.image_version}/metal-amd64.iso"
  file_name    = "talos_${var.talos.image_version}_metal-amd64.iso"
  overwrite    = true
  # decompression_algorithm = "zst"
}
