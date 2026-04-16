# # Cloud SQL PostgreSQL インスタンス
# resource "google_sql_database_instance" "main" {
#   name             = "${var.prefix}-postgres-instance"
#   project          = var.base_project_id
#   region           = var.region
#   database_version = "POSTGRES_15"

#   deletion_protection = true

#   settings {
#     tier              = "db-custom-2-7680"  # 2vCPU, 7.5GB RAM
#     availability_type = "REGIONAL"          # 高可用性構成（マルチゾーン）
#     disk_type         = "PD_SSD"
#     disk_size         = 100
#     disk_autoresize   = true
#     disk_autoresize_limit = 500

#     backup_configuration {
#       enabled                        = true
#       start_time                     = "03:00"
#       transaction_log_retention_days = 7
#       backup_retention_settings {
#         retained_backups = 30
#       }
#     }

#     ip_configuration {
#       ipv4_enabled    = false
#       private_network = module.vpc.network_self_link
#       ssl_mode        = "ENCRYPTED_ONLY"
#     }

#     maintenance_window {
#       day          = 7  # 日曜日
#       hour         = 4  # 午前4時
#       update_track = "stable"
#     }

#     database_flags {
#       name  = "max_connections"
#       value = "100"
#     }

#     database_flags {
#       name  = "cloudsql.iam_authentication"
#       value = "on"
#     }

#     insights_config {
#       query_insights_enabled  = true
#       query_string_length     = 1024
#       record_application_tags = true
#       record_client_address   = true
#     }
#   }

#   depends_on = [google_service_networking_connection.private_vpc_connection]
# }

# # デフォルトデータベース
# resource "google_sql_database" "database" {
#   name     = "${var.prefix}-db"
#   instance = google_sql_database_instance.main.name
#   project  = var.base_project_id
# }

# # ランダムパスワード生成
# resource "random_password" "db_password" {
#   length  = 32
#   special = true
# }

# # データベースユーザー
# resource "google_sql_user" "users" {
#   name     = "${var.prefix}-user"
#   instance = google_sql_database_instance.main.name
#   password = random_password.db_password.result
#   project  = var.base_project_id
# }

# # Secret Managerにパスワードを保存
# resource "google_secret_manager_secret" "db_password" {
#   secret_id = "${var.prefix}-db-password"
#   project   = var.base_project_id

#   replication {
#     auto {}
#   }

#   labels = merge(
#     local.common_tags,
#     {
#       "resource" = "db-password"
#     }
#   )
# }

# resource "google_secret_manager_secret_version" "db_password" {
#   secret      = google_secret_manager_secret.db_password.id
#   secret_data = random_password.db_password.result
# }

# # GKE Workload Identity用のIAMバインディング（必要に応じてコメント解除）
# # resource "google_project_iam_member" "cloudsql_client" {
# #   project = var.base_project_id
# #   role    = "roles/cloudsql.client"
# #   member  = "serviceAccount:${google_service_account.gke_workload_sa.email}"
# # }

# # Secret Manager アクセス権限（必要に応じてコメント解除）
# # resource "google_secret_manager_secret_iam_member" "secret_access" {
# #   secret_id = google_secret_manager_secret.db_password.id
# #   role      = "roles/secretmanager.secretAccessor"
# #   member    = "serviceAccount:${google_service_account.gke_workload_sa.email}"
# # }
