# Test cluster with multiple node pools for parallel upgrade testing
resource "google_container_cluster" "cluster_multi" {
  project = var.base_project_id

  name     = "${var.prefix}-cluster-multi"
  location = var.region

  enable_shielded_nodes    = false
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  private_cluster_config {
    enable_private_endpoint = "false"
    enable_private_nodes    = "true"
    master_ipv4_cidr_block  = "172.16.1.0/28"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "106.156.42.67/32"
      display_name = "Current IP"
    }
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = local.pod_secondary_range
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
    dns_cache_config {
      enabled = true
    }
    gcs_fuse_csi_driver_config {
      enabled = true
    }
  }

  workload_identity_config {
    workload_pool = "${var.base_project_id}.svc.id.goog"
  }

  release_channel {
    channel = "UNSPECIFIED"
  }
}

# Node Pool 1
resource "google_container_node_pool" "cluster_multi_pool_1" {
  name     = "pool-1"
  project  = var.base_project_id
  cluster  = google_container_cluster.cluster_multi.name
  location = var.region

  initial_node_count = 1
  autoscaling {
    max_node_count = 2
    min_node_count = 1
  }

  node_config {
    preemptible     = "false"
    machine_type    = "e2-small"
    disk_size_gb    = 50
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
      node-pool-type = "pool-1"
    }
  }

  management {
    auto_repair  = "true"
    auto_upgrade = "false"
  }

  version = "1.35.2-gke.1269001"

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  max_pods_per_node = "110"
}

# Node Pool 2
resource "google_container_node_pool" "cluster_multi_pool_2" {
  name     = "pool-2"
  project  = var.base_project_id
  cluster  = google_container_cluster.cluster_multi.name
  location = var.region

  initial_node_count = 1
  autoscaling {
    max_node_count = 2
    min_node_count = 1
  }

  node_config {
    preemptible     = "false"
    machine_type    = "e2-small"
    disk_size_gb    = 50
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
      node-pool-type = "pool-2"
    }
  }

  management {
    auto_repair  = "true"
    auto_upgrade = "false"
  }

  version = "1.35.2-gke.1269001"

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  max_pods_per_node = "110"
}

# Node Pool 3
resource "google_container_node_pool" "cluster_multi_pool_3" {
  name     = "pool-3"
  project  = var.base_project_id
  cluster  = google_container_cluster.cluster_multi.name
  location = var.region

  initial_node_count = 1
  autoscaling {
    max_node_count = 2
    min_node_count = 1
  }

  node_config {
    preemptible     = "false"
    machine_type    = "e2-small"
    disk_size_gb    = 50
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
      node-pool-type = "pool-3"
    }
  }

  management {
    auto_repair  = "true"
    auto_upgrade = "false"
  }

  version = "1.35.2-gke.1269001"

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  max_pods_per_node = "110"
}
