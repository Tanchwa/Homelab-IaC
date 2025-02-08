/* resource "null_resource" "download_image_locally" {

  provisioner "local-exec" {
    command = "mkdir -p /tmp/terraform/images && wget https://github.com/home-assistant/operating-system/releases/download/${var.home_assistant.image_version}/haos_ova-${var.home_assistant.image_version}.qcow2.xz -O /tmp/terraform/images/haos_generic-x86-${var.home_assistant.image_version}.qcow2.img.xz && unxz -qk /tmp/terraform/images/haos_generic-x86-${var.home_assistant.image_version}.qcow2.img.xz"
    quiet   = true
  }

} 

resource "proxmox_virtual_environment_file" "home_assistant_img" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "proxmox"

  source_file {
    path = "/tmp/terraform/images/haos_generic-x86-${var.home_assistant.image_version}.qcow2.img"
  }

} */

resource "proxmox_virtual_environment_download_file" "home_assistant_img" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.proxmox_node_name
  url          = format("https://github.com/home-assistant/operating-system/releases/download/%[1]s/haos_ova-%[1]s.qcow2.xz", var.home_assistant.image_version)
  file_name    = format("haos_generic-x86-%s.qcow2.img", var.home_assistant.image_version)
  overwrite    = false
}

resource "null_resource" "unpack_home_assistant_img" {
  triggers = {
    download_file_id = proxmox_virtual_environment_download_file.home_assistant_img.id
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key_path)
    host        = "172.31.0.200"
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = ["mv /var/lib/vz/template/iso/haos_generic-x86-${var.home_assistant.image_version}.qcow2.img /var/lib/vz/template/iso/haos_generic-x86-${var.home_assistant.image_version}.qcow2.img.xz",
    "unxz -qk /var/lib/vz/template/iso/haos_generic-x86-${var.home_assistant.image_version}.qcow2.img.xz"]
  }


}
