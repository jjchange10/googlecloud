# GitHub Actions用のサービスアカウント
resource "google_service_account" "github_actions" {
  account_id   = "github-actions-gke-admin"
  display_name = "GitHub Actions GKE Admin"
  description  = "Service account for GitHub Actions to manage GKE clusters"
}

# GKE管理に必要な権限
locals {
  github_actions_roles = [
    "roles/container.clusterAdmin",  # GKEクラスターの管理
    "roles/container.developer",     # GKEクラスターの操作
    "roles/iam.serviceAccountUser",  # サービスアカウントの使用
  ]
}

resource "google_project_iam_member" "github_actions_roles" {
  for_each = toset(local.github_actions_roles)

  project = var.base_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Workload Identity Pool作成
resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Workload Identity Pool for GitHub Actions"
}

# GitHub用のWorkload Identity Provider
resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider"
  display_name                       = "GitHub Actions Provider"
  description                        = "OIDC provider for GitHub Actions"

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  attribute_condition = "assertion.repository_owner == '${split("/", var.github_repository)[0]}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# サービスアカウントへのアクセス許可
# 特定のGitHubリポジトリからのみアクセスを許可
resource "google_service_account_iam_member" "github_actions_workload_identity" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repository}"
}
