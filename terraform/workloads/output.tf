output "zones" {
  value = local.zones
}

output "subnet_name" {
  value = module.vpc.network_name
}

output "kube_system_namespace_uid" {
  value = data.kubernetes_namespace_v1.kube_system.metadata[0].uid
}

# GitHub Actions用のWorkload Identity情報
output "github_actions_workload_identity_provider" {
  description = "Workload Identity ProviderのリソースID（GitHub ActionsのWIF_PROVIDERシークレットに設定）"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "github_actions_service_account_email" {
  description = "GitHub Actions用サービスアカウントのメールアドレス（GitHub ActionsのWIF_SERVICE_ACCOUNTシークレットに設定）"
  value       = google_service_account.github_actions.email
}
