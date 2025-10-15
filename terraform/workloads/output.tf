output "zones" {
  value = local.zones
}

output "subnet_name" {
  value = module.vpc.network_name
}

output "kube_system_namespace_uid" {
  value = data.kubernetes_namespace_v1.kube_system.metadata[0].uid
}
