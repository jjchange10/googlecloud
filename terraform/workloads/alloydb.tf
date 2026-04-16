# # AlloyDB クラスター
# resource "google_alloydb_cluster" "main" {
#   cluster_id   = "${var.prefix}-alloydb-cluster"
#   location     = var.region
#   project      = var.base_project_id
#   network_config {
#     network = module.vpc.network_id
#   }

#   initial_user {
#     user     = "${var.prefix}-admin"
#     password = random_password.alloydb_password.result
#   }

#   automated_backup_policy {
#     location      = var.region
#     backup_window = "03:00"
#     enabled       = true

#     weekly_schedule {
#       days_of_week = ["MONDAY", "WEDNESDAY", "FRIDAY"]
#       start_times {
#         hours   = 3
#         minutes = 0
#       }
#     }

#     quantity_based_retention {
#       count = 30
#     }

#     labels = merge(
#       local.common_tags,
#       {
#         "resource" = "alloydb-backup"
#       }
#     )
#   }

#   labels = merge(
#     local.common_tags,
#     {
#       "resource" = "alloydb-cluster"
#     }
#   )

#   depends_on = [google_service_networking_connection.private_vpc_connection]
# }

# # AlloyDB プライマリインスタンス
# resource "google_alloydb_instance" "primary" {
#   cluster       = google_alloydb_cluster.main.name
#   instance_id   = "${var.prefix}-alloydb-primary"
#   instance_type = "PRIMARY"

#   machine_config {
#     cpu_count = 2
#   }

#   availability_type = "REGIONAL"

#   database_flags = {
#     "max_connections" = "100"
#   }

#   labels = merge(
#     local.common_tags,
#     {
#       "resource" = "alloydb-primary-instance"
#     }
#   )
# }

# # AlloyDB リードレプリカインスタンス（オプション）
# # resource "google_alloydb_instance" "read_pool" {
# #   cluster       = google_alloydb_cluster.main.name
# #   instance_id   = "${var.prefix}-alloydb-read-pool"
# #   instance_type = "READ_POOL"
# #
# #   machine_config {
# #     cpu_count = 2
# #   }
# #
# #   read_pool_config {
# #     node_count = 2
# #   }
# #
# #   labels = merge(
# #     local.common_tags,
# #     {
# #       "resource" = "alloydb-read-pool"
# #     }
# #   )
# # }

# # ランダムパスワード生成（AlloyDB用）
# resource "random_password" "alloydb_password" {
#   length  = 32
#   special = true
# }

# # Secret Managerにパスワードを保存
# resource "google_secret_manager_secret" "alloydb_password" {
#   secret_id = "${var.prefix}-alloydb-password"
#   project   = var.base_project_id

#   replication {
#     auto {}
#   }

#   labels = merge(
#     local.common_tags,
#     {
#       "resource" = "alloydb-password"
#     }
#   )
# }

# resource "google_secret_manager_secret_version" "alloydb_password" {
#   secret      = google_secret_manager_secret.alloydb_password.id
#   secret_data = random_password.alloydb_password.result
# }

# # GKE Workload Identity用のIAMバインディング（必要に応じてコメント解除）
# # resource "google_project_iam_member" "alloydb_client" {
# #   project = var.base_project_id
# #   role    = "roles/alloydb.client"
# #   member  = "serviceAccount:${google_service_account.gke_workload_sa.email}"
# # }

# # Secret Manager アクセス権限（必要に応じてコメント解除）
# # resource "google_secret_manager_secret_iam_member" "alloydb_secret_access" {
# #   secret_id = google_secret_manager_secret.alloydb_password.id
# #   role      = "roles/secretmanager.secretAccessor"
# #   member    = "serviceAccount:${google_service_account.gke_workload_sa.email}"
# # }
