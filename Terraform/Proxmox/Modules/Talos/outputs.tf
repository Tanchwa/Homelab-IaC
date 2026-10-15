# Talos reports every kernel network interface to the guest agent (lo, bond0,
# dummy0, teql0, tunl0, sit0, ip6tnl0, ...), most with no address - and now
# that each node has a second real NIC on the internal vmbr2 bridge (see
# ../../network.tf), there are two genuine non-loopback addresses to pick
# from, not one. Match the primary LAN's subnet explicitly instead of just
# "first non-loopback, non-link-local" to keep this output pointing at the
# same address it always has (cluster_endpoint, talosctl/kubectl access).
# Requires the qemu-guest-agent system extension (see node-config/image.yaml),
# which reports an IP even in maintenance mode.
output "ipv4_address" {
  value = try(
    [for ip in flatten(proxmox_virtual_environment_vm.talos_controlplane_vm[0].ipv4_addresses) : ip if startswith(ip, "172.31.")][0],
    [for ip in flatten(proxmox_virtual_environment_vm.talos_worker_vm[0].ipv4_addresses) : ip if startswith(ip, "172.31.")][0],
    null
  )
}

# The node's address on the internal, physical-LAN-bypassing bridge - not
# consumed anywhere yet, but available for whatever ends up using the direct
# path (e.g. repointing Cilium's tunnel endpoint there later).
output "internal_ipv4_address" {
  value = try(
    [for ip in flatten(proxmox_virtual_environment_vm.talos_controlplane_vm[0].ipv4_addresses) : ip if startswith(ip, "10.99.")][0],
    [for ip in flatten(proxmox_virtual_environment_vm.talos_worker_vm[0].ipv4_addresses) : ip if startswith(ip, "10.99.")][0],
    null
  )
}
