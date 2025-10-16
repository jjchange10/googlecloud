data "google_client_config" "current" {}

provider "kubernetes" {
  host = "https://${google_container_cluster.cluster.endpoint}"
  token = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.cluster.master_auth[0].cluster_ca_certificate)
}

resource "google_container_cluster" "cluster" {
  project = var.base_project_id

  name     = "${var.prefix}-cluster"
  location = var.region
  min_master_version = "1.33.5-gke.1080000"

  enable_shielded_nodes    = false
  remove_default_node_pool = true # 下記の自分たちで作成したnodeを利用するために、defaultのnode_poolを削除
  initial_node_count       = 1
  deletion_protection      = false

  private_cluster_config {
    # NOTE! enable_private_endpoint shoud be "true", but changing this value is force replacement.
    enable_private_endpoint = "false"
    enable_private_nodes    = "true"
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
  # this config required to enable master-authorized-networks see following document.
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#master_authorized_networks_config
  # https://cloud.google.com/kubernetes-engine/docs/concepts/private-cluster-concept?hl=ja
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "106.156.42.67/32"
      display_name = "Current IP"
    }
  }

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/using_gke_with_terraform#vpc-native-clusters
  ip_allocation_policy {
    cluster_secondary_range_name = local.pod_secondary_range
    services_secondary_range_name = local.service_secondary_range
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  network    = module.vpc.network_name
  subnetwork = module.vpc.subnets_names[0]

  network_policy {
    enabled  = "true"
    provider = "CALICO"
  }

  addons_config {
    http_load_balancing {
      disabled = "false"
    }
    network_policy_config {
      disabled = "false"
    }
    # NodeLocal DNSCache
    dns_cache_config {
      enabled = true
    }
    gcs_fuse_csi_driver_config {
      enabled = true
    }
  }
  # Docs: https://cloud.google.com/kubernetes-engine/docs/how-to/node-auto-upgrades
  # Other note: https://medium.com/google-cloud-jp/gke-lts-a92c8fc2f9a
  # maintenance_policy {
  #   recurring_window {
  #     # 平日の日本時間午前2-6時
  #     # 2019-01-01T02:00:00+09:00 - 2019-01-01T06:00:00+09:00
  #     start_time = "2025-10-08T15:00:37Z"
  #     end_time   = "2025-10-08T20:00:37Z"
  #     recurrence = "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR"
  #   }
  # }

  workload_identity_config {
    workload_pool = "${var.base_project_id}.svc.id.goog"
  }

  release_channel {
    channel = "UNSPECIFIED"
  }

}

resource "google_container_node_pool" "cluster_base_pool" {
  name     = "${var.prefix}-base-node-pool"
  project  = var.base_project_id
  cluster  = google_container_cluster.cluster.name
  location = var.region

  initial_node_count = 1
  autoscaling {
    max_node_count = 2
    min_node_count = 2
  }

  #tfsec:ignore:google-gke-node-pool-uses-cos
  node_config {
    preemptible     = "false"
    machine_type    = "e2-medium"
    disk_size_gb    = 100
    local_ssd_count = 0

    metadata = {
      disable-legacy-endpoints = true
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    service_account = google_service_account.test_cluster.email

    shielded_instance_config {
      enable_integrity_monitoring = "true"
      enable_secure_boot          = "false"
    }

    labels = {
      node-pool-type = "base"
    }
  }

  management {
    auto_repair  = "true"
    auto_upgrade = "false"
  }

  version = "1.33.5-gke.1080000"

  upgrade_settings {
    max_surge       = 2
    max_unavailable = 0
  }

  max_pods_per_node = "110"
}
