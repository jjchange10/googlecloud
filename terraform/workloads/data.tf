data "google_compute_zones" "available" {
}

data "kubernetes_namespace_v1" "kube_system" {
  metadata {
    name = "kube-system"
  }
  depends_on = [ google_container_cluster.cluster ]
}
