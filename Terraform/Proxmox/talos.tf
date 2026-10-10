# Talos cluster bootstrap: machine secrets -> per-role machine config -> apply
# to each node -> bootstrap etcd on the controlplane -> retrieve kubeconfig.
# Single controlplane node, so the API endpoint is just its IP - no LB/VIP.

locals {
  controlplane_ip = module.talos_controlplane.ipv4_address
  worker_ips      = module.talos_worker[*].ipv4_address
}

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name       = var.cluster_name
  machine_type       = "controlplane"
  cluster_endpoint   = "https://${local.controlplane_ip}:6443"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  config_patches = [
    yamlencode({
      machine = {
        install = {
          image = local.talos_installer_image
        }
      }
      cluster = {
        allowSchedulingOnControlPlanes = true
      }
    }),
    file("${path.module}/node-config/cluster.yaml"),
    file("${path.module}/node-config/controlplane.yaml"),
  ]
}

data "talos_machine_configuration" "worker" {
  cluster_name       = var.cluster_name
  machine_type       = "worker"
  cluster_endpoint   = "https://${local.controlplane_ip}:6443"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  config_patches = [
    yamlencode({
      machine = {
        install = {
          image = local.talos_installer_image
        }
      }
    }),
    file("${path.module}/node-config/cluster.yaml"),
    file("${path.module}/node-config/worker.yaml"),
  ]
}

resource "talos_machine_configuration_apply" "controlplane" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = local.controlplane_ip
  endpoint                    = local.controlplane_ip
}

resource "talos_machine_configuration_apply" "worker" {
  for_each = { for idx, ip in local.worker_ips : tostring(idx) => ip }

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value
  endpoint                    = each.value
}

# Bootstrap etcd on the single controlplane node.
resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.controlplane_ip
  endpoint             = local.controlplane_ip

  depends_on = [talos_machine_configuration_apply.controlplane]
}

# Fixed sleep instead of talos_cluster_health: nodes are still finishing their
# first boot/install cycle immediately after bootstrap, which can cause apid
# timeouts if health is checked too early (same tradeoff ai-grid makes).
resource "time_sleep" "wait_for_cluster" {
  create_duration = "3m"
  depends_on      = [talos_machine_bootstrap.this]
}

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.controlplane_ip
  endpoint             = local.controlplane_ip

  depends_on = [time_sleep.wait_for_cluster]
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [local.controlplane_ip]
  nodes                = [local.controlplane_ip]
}

output "kubeconfig_raw" {
  description = "Raw kubeconfig for the Talos cluster."
  sensitive   = true
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
}

output "talosconfig" {
  description = "Talosconfig for cluster access."
  sensitive   = true
  value       = data.talos_client_configuration.this.talos_config
}

