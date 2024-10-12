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
  node_name    = var.proxmox_node_name
  url          = "https://github.com/home-assistant/operating-system/releases/download/12.2/haos_ova-12.2.qcow2.xz"
  file_name    = "haos_generic-x86-12.2.img"
  overwrite    = false
}

resource "null_resource" "unpack_home_assistant_img" {
  triggers = {
    always_run = timestamp()
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key_path)
    host        = "172.31.0.200"
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = ["mv /var/lib/vz/template/iso/haos_generic-x86-12.2.img /var/lib/vz/template/iso/haos_generic-x86-12.2.img.xz",
    "unxz -qk /var/lib/vz/template/iso/haos_generic-x86-12.2.img.xz"]
  }



  depends_on = [proxmox_virtual_environment_download_file.home_assistant_img]
}
