resource "google_container_cluster" "test_cluster_autopilot" {
    name = "${var.prefix}-cluster-autopilot"
    project = var.base_project_id
    location = var.region
    network = module.vpc.network_name
    subnetwork = module.vpc.subnets_names[0]
    deletion_protection = false
    enable_autopilot = true
    release_channel {
        channel = "REGULAR"
    }

    networking_mode = "VPC_NATIVE"
    cluster_autoscaling {
      auto_provisioning_defaults {
        service_account = google_service_account.test_cluster.email
      }
    }

    ip_allocation_policy {
      cluster_secondary_range_name = local.pod_secondary_range
      services_secondary_range_name = local.service_secondary_range
    }

    private_cluster_config {
      enable_private_nodes = true
      master_ipv4_cidr_block = "172.0.0.0/28"
    }
    master_authorized_networks_config {
      cidr_blocks {
        cidr_block = "106.156.42.67/32"
        display_name = "3-shake VPN"
      }
    }

    node_pool_auto_config {
      network_tags {
        tags= ["wordpress"]
      }
    }    
}
