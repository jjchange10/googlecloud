terraform {
  required_version = ">= 1.9.0"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.36.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}

provider "google" {
  project = var.base_project_id
  region = var.region
}

provider "helm" {
  kubernetes = {
    host = "https://${google_container_cluster.cluster.endpoint}"
    token = data.google_client_config.current.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.cluster.master_auth[0].cluster_ca_certificate)
  }
}
