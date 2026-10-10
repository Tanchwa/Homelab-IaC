# Talos reports every kernel network interface to the guest agent (lo, bond0,
# dummy0, teql0, tunl0, sit0, ip6tnl0, ...), most with no address - the real
# NIC's IP can land at any index depending on how many of those exist, so
# flatten everything and take the first non-empty, non-loopback, non-link-local
# address instead of assuming a fixed position. Link-local (169.254.0.0/16)
# addresses show up on interfaces that never got a DHCP lease (e.g. a bond
# member or dummy interface) and must be excluded or they get picked over the
# real DHCP address. Requires the qemu-guest-agent system extension (see
# node-config/image.yaml), which reports an IP even in maintenance mode.
output "ipv4_address" {
  value = try(
    [for ip in flatten(proxmox_virtual_environment_vm.talos_controlplane_vm[0].ipv4_addresses) : ip if ip != "" && ip != "127.0.0.1" && !startswith(ip, "169.254.")][0],
    [for ip in flatten(proxmox_virtual_environment_vm.talos_worker_vm[0].ipv4_addresses) : ip if ip != "" && ip != "127.0.0.1" && !startswith(ip, "169.254.")][0],
    null
  )
}
