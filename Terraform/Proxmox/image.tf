# Builds the Talos boot image once, shared by every node. Sidero Image Factory:
# upload the schematic (system extensions) to get a schematic ID, then download
# the matching ISO for this Talos version. Proxmox boots Image Factory's hosted
# ISO directly - no local `imager` docker build required.
#
# This used to live inside Modules/Talos and run once per node module instance
# (controlplane + 2 workers), which meant three separate Terraform resources
# independently downloading the identical ISO to the identical destination
# path on the same Proxmox node - a race that could corrupt the file under
# concurrent applies. Built once here instead, and the resulting file_id /
# installer_image are passed into each node module.
data "http" "talos_schematic" {
  url    = "https://factory.talos.dev/schematics"
  method = "POST"

  request_headers = {
    "Content-Type" = "text/yaml"
  }

  request_body = file("${path.module}/node-config/image.yaml")
}

locals {
  talos_schematic_id    = jsondecode(data.http.talos_schematic.response_body).id
  talos_installer_image = "factory.talos.dev/installer/${local.talos_schematic_id}:${var.talos_version}"
}

resource "proxmox_virtual_environment_download_file" "talos_img" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "proxmox"
  url          = "https://factory.talos.dev/image/${local.talos_schematic_id}/${var.talos_version}/metal-amd64.iso"
  file_name    = "talos_${var.talos_version}_${substr(local.talos_schematic_id, 0, 12)}_metal-amd64.iso"
  overwrite    = true
}
