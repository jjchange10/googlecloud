## K8sクラスタのサービスアカウント
locals {
    cluster_roles = [
        "roles/container.defaultNodeServiceAccount",
        "roles/artifactregistry.reader",
    ]
    opentelemetry_roles = [
        "roles/logging.logWriter",
        "roles/monitoring.metricWriter",
        "roles/serviceusage.serviceUsageConsumer",
        "roles/cloudtrace.agent",
        "roles/iam.serviceAccountTokenCreator",
    ]
}

resource "google_project_iam_member" "service_account_roles" {
  for_each = toset(local.cluster_roles)

  project = var.base_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.test_cluster.email}"
}

resource "google_service_account" "test_cluster" {
    account_id = "test-cluster-user"
    display_name = "Test Cluster User"
}
