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

# GCS outputs（使用する場合はgcs.tfのリソースのコメントを解除してください）
# output "gcs_bucket_name" {
#   description = "GCSバケット名"
#   value       = google_storage_bucket.main.name
# }

# output "gcs_bucket_url" {
#   description = "GCSバケットURL"
#   value       = google_storage_bucket.main.url
# }

# Cloud SQL outputs（使用する場合はcloudsql.tfのリソースのコメントを解除してください）
# output "cloudsql_instance_name" {
#   description = "Cloud SQLインスタンス名"
#   value       = google_sql_database_instance.main.name
# }

# output "cloudsql_connection_name" {
#   description = "Cloud SQL接続名（GKEから接続する際に使用）"
#   value       = google_sql_database_instance.main.connection_name
# }

# output "cloudsql_private_ip" {
#   description = "Cloud SQLプライベートIPアドレス"
#   value       = google_sql_database_instance.main.private_ip_address
# }

# output "database_name" {
#   description = "データベース名"
#   value       = google_sql_database.database.name
# }

# output "database_user" {
#   description = "データベースユーザー名"
#   value       = google_sql_user.users.name
# }

# output "database_password_secret_id" {
#   description = "データベースパスワードのSecret Manager ID"
#   value       = google_secret_manager_secret.db_password.secret_id
#   sensitive   = true
# }

# AlloyDB outputs（使用する場合はalloydb.tfのリソースのコメントを解除してください）
# output "alloydb_cluster_name" {
#   description = "AlloyDBクラスター名"
#   value       = google_alloydb_cluster.main.name
# }

# output "alloydb_cluster_id" {
#   description = "AlloyDBクラスターID"
#   value       = google_alloydb_cluster.main.cluster_id
# }

# output "alloydb_primary_instance_name" {
#   description = "AlloyDBプライマリインスタンス名"
#   value       = google_alloydb_instance.primary.name
# }

# output "alloydb_primary_ip_address" {
#   description = "AlloyDBプライマリインスタンスのIPアドレス"
#   value       = google_alloydb_instance.primary.ip_address
# }

# output "alloydb_connection_string" {
#   description = "AlloyDB接続文字列（パスワードは別途Secret Managerから取得）"
#   value       = "host=${google_alloydb_instance.primary.ip_address} port=5432 user=${google_alloydb_cluster.main.initial_user[0].user} dbname=postgres sslmode=require"
#   sensitive   = true
# }

# output "alloydb_user" {
#   description = "AlloyDBユーザー名"
#   value       = google_alloydb_cluster.main.initial_user[0].user
# }

# output "alloydb_password_secret_id" {
#   description = "AlloyDBパスワードのSecret Manager ID"
#   value       = google_secret_manager_secret.alloydb_password.secret_id
#   sensitive   = true
# }
