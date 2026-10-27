resource "kubernetes_namespace_v1" "argo" {
  metadata {
    name = "argocd"
  }

  timeouts {
    delete = "20m"
  }

  depends_on = [time_sleep.wait_for_cluster]
}

// needs rbac on cluster ahead of time
// gave the backend service account cluster-developer role
resource "helm_release" "argo" {
  name       = "argo"
  repository = "oci://ghcr.io/argoproj/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace_v1.argo.metadata[0].name
  version    = "9.2.3"

  values = [
    file("${path.module}/argo-values.yaml")
  ]

  depends_on = [kubernetes_namespace_v1.argo]
}
