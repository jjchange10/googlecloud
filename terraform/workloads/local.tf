locals {
    zones = slice(data.google_compute_zones.available.names, 0, 3)
}

locals {
  secondary_ranges = flatten(module.vpc.subnets_secondary_ranges)
}

locals {
  pod_secondary_range = [for r in local.secondary_ranges : r.range_name if r.range_name == "gke-pods-range"][0]
  service_secondary_range = [for r in local.secondary_ranges : r.range_name if r.range_name == "gke-services-range"][0]
}

locals {
  common_tags = {
    "environment" = "dev"
    "managedby" = "terraform"
  }
}
