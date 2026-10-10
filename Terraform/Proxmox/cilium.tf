# Cilium as CNI + bare-metal LB (L2 announcements + externalIPs), replacing the
# manual `cilium install` CLI step from Ansible/Nodes/roles/cni/tasks/cilium.yaml.
# Manifests/Networking/cilium-l2-announcement-policy.yaml and cilium-lb-pool.yaml
# (synced separately via ArgoCD) depend on l2announcements/externalIPs being
# enabled here.
resource "helm_release" "cilium" {
  name             = "cilium"
  repository       = "https://helm.cilium.io"
  chart            = "cilium"
  version          = var.cilium_version
  namespace        = "kube-system"
  create_namespace = false

  values = [yamlencode({
    kubeProxyReplacement = true
    k8sServiceHost       = "localhost"
    # kubePrism port
    k8sServicePort = 7445

    devices = "^enp+|^eth+"

    l2announcements = {
      enabled              = true
      leaseDuration        = "25s"
      leaseRenewalDeadline = "15s"
      leaseRetryPeriod     = "8s"
    }

    externalIPs = {
      enabled = true
    }

    k8sClientRateLimit = {
      qps   = 3000
      burst = 20000
    }

    securityContext = {
      privileged = true

      capabilities = {
        # enable all except for SYS_MODULE, which is not supported in Talos
        ciliumAgent = [
          "CHOWN",
          "KILL",
          "NET_ADMIN",
          "NET_RAW",
          "IPC_LOCK",
          "SYS_ADMIN",
          "SYS_RESOURCE",
          "DAC_OVERRIDE",
          "FOWNER",
          "SETGID",
          "SETUID",
          "SYSLOG"
        ]
        cleanCiliumState = [
          "NET_ADMIN",
          "SYS_ADMIN",
          "SYS_RESOURCE"
        ]
      }
    }

    ipam = {
      mode = "kubernetes"
    }

    cgroup = {
      autoMount = {
        enabled = false
      }
      hostRoot = "/sys/fs/cgroup"
    }

    # Remove the node.cilium.io/agent-not-ready taint automatically once Cilium
    # is running on each node so pods can be scheduled.
    operator = {
      removeCiliumNodeTaints = true
    }

    # TC-level fallback for ClusterIP access from the host network namespace -
    # the kube-apiserver (hostNetwork static pod) on Talos runs in a cgroup
    # namespace that Cilium's socket LB hook cannot see, so webhook calls to
    # ClusterIP services would otherwise time out.
    bpf = {
      lbExternalClusterIP = true
    }
  })]

  timeout = 480

  depends_on = [talos_cluster_kubeconfig.this]
}
