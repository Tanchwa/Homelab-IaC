# Internal-only bridge for direct Talos <-> pfSense connectivity, bypassing
# the physical LAN (vmbr0) - no `ports` means no physical NIC is attached, so
# traffic on this bridge never leaves the Proxmox host's own virtual switch.
# pfSense gets a NIC on this too (added manually, see note below - pfSense
# isn't Terraform-managed) at 10.99.0.1.
resource "proxmox_virtual_environment_network_linux_bridge" "internal" {
  node_name = "proxmox"
  name      = "vmbr2"
  address   = "10.99.0.200/24"
  comment   = "Internal-only - direct Talos/pfSense path, no physical NIC"
}

# pfSense (VM 100) is not managed by this Terraform as a full resource - it's
# hand-built, with passthrough NICs for its existing ixl0/ixl1 WAN/LAN, and
# importing the whole VM just to manage one NIC risks Terraform wanting to
# "fix" the passthrough hardware config on a live router. Instead, this runs
# the one `qm set` command over SSH (same credentials as the proxmox provider
# in providers.tf) so `terraform apply` does it without a manual CLI step -
# it's a one-time triggered action, not a continuously-reconciled resource,
# so Terraform won't detect or correct drift here the way it would for a
# real managed resource.
resource "null_resource" "pfsense_internal_nic" {
  depends_on = [proxmox_virtual_environment_network_linux_bridge.internal]

  triggers = {
    # Re-run if the bridge name or this NIC's intended MAC ever changes.
    bridge = proxmox_virtual_environment_network_linux_bridge.internal.name
    mac    = "02:00:00:99:00:01"
  }

  connection {
    type        = "ssh"
    host        = "172.31.0.200"
    user        = "root"
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "qm set 100 --net2 virtio,bridge=${proxmox_virtual_environment_network_linux_bridge.internal.name},firewall=0,macaddr=02:00:00:99:00:01",
    ]
  }
}

# Then configure the interface inside pfSense itself (static 10.99.0.1/24)
# via Ansible/Networking/playbook.router-install.yaml, matching how ixl0/ixl1
# are already configured there - that part still needs to run separately,
# since it's pfSense's own config (via its API), not Proxmox hardware.
