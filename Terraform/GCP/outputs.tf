output "ip_addresses" {
  value = {
    for instance in [google_compute_instance.cks-master, google_compute_instance.cks-worker] :
    instance.id => instance.network_interface[0].access_config[0].nat_ip
  }
}
