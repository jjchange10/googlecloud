# resource "google_storage_bucket" "main" {
#   name          = "${var.prefix}-${var.base_project_id}-bucket"
#   project       = var.base_project_id
#   location      = var.region
#   force_destroy = false

#   versioning {
#     enabled = true
#   }

#   lifecycle_rule {
#     condition {
#       age = 90
#     }
#     action {
#       type = "Delete"
#     }
#   }

#   lifecycle_rule {
#     condition {
#       age                   = 30
#       with_state            = "ANY"
#       num_newer_versions    = 3
#     }
#     action {
#       type = "Delete"
#     }
#   }

#   labels = merge(
#     local.common_tags,
#     {
#       "resource" = "storage-bucket"
#     }
#   )
# }

# # バケット用のIAMバインディング（必要に応じてコメント解除）
# # resource "google_storage_bucket_iam_member" "member" {
# #   bucket = google_storage_bucket.main.name
# #   role   = "roles/storage.objectViewer"
# #   member = "serviceAccount:${google_service_account.gke_workload_sa.email}"
# # }
