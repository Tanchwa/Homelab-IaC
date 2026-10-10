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

    # Cilium's device matcher is NOT regex - it's a plain name or an
    # iptables-style trailing "+" wildcard (comma-separated for multiple
    # patterns). "^enp+|^eth+" was invalid syntax and almost certainly
    # matched nothing, which is why direct-routing-device auto-detection
    # kept failing even after routingMode/nodePort.directRoutingDevice were
    # added below - enp6s18 (confirmed identical across all 3 nodes via
    # Modules/Talos/outputs.tf's IP-discovery debugging) matches "enp+".
    devices = "enp+,eth+"

    # Explicit tunnel/vxlan mode, not native routing - pod-to-pod routing
    # doesn't need to know which physical NIC each node has.
    routingMode    = "tunnel"
    tunnelProtocol = "vxlan"

    # Separate from pod-to-pod routing mode: kubeProxyReplacement's eBPF
    # NodePort/LoadBalancer datapath (and bpf.lbExternalClusterIP below) needs
    # its own "direct routing device" regardless of tunnel vs native mode.
    nodePort = {
      directRoutingDevice = "enp+,eth+"
    }

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

    hubble = {
      enabled = true
      relay = {
        enabled = true
      }
      ui = {
        enabled = true
      }
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
