module "vpc" {
  source = "terraform-google-modules/network/google"
  version = "11.1.0"

  project_id = var.base_project_id
  network_name = "${var.prefix}-vpc"
  routing_mode = "REGIONAL"
  subnets = [
    {
      subnet_name = "${var.prefix}-subnet"
      subnet_ip = "10.0.0.0/16"
      subnet_region = var.region
    }
  ]
  secondary_ranges = {
    "${var.prefix}-subnet" = [
        {
            range_name = "gke-pods-range"
            ip_cidr_range = "172.17.0.0/20"
        },
        {
            range_name = "gke-services-range"
            ip_cidr_range = "172.18.0.0/22"
        },
    ]
  }
}

resource "google_compute_router" "router" {
  name    = "${var.prefix}-nat-router"
  network = module.vpc.network_name
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.prefix}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.prefix}-private-ip-address"
  purpose = "VPC_PEERING"
  address_type  = "INTERNAL"
  address = "10.100.0.0"
  prefix_length = 24
  network       = module.vpc.network.network_self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network       = module.vpc.network_name
  service       = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    google_compute_global_address.private_ip_address.name,
    google_compute_global_address.filestore_private_ip_address.name,
  ]
}

resource "google_compute_global_address" "filestore_private_ip_address" {
  name          = "${var.prefix}-filestore-private-ip-address"
  purpose = "VPC_PEERING"
  address_type  = "INTERNAL"
  address = "10.101.0.0"
  prefix_length = 24
  network       = module.vpc.network.network_self_link
}
