variable "base_project_id" {
  type = string
}

variable "region" {
  type = string
  default = "asia-northeast1"
}

variable "project_services_list" {
  description = "有効化するGoogleクラウドサービスのリスト"
  type        = list(string)
  default     = [
    "container.googleapis.com",
    "servicenetworking.googleapis.com",
    "networkmanagement.googleapis.com",
    "sqladmin.googleapis.com",
    "file.googleapis.com",
    "memorystore.googleapis.com",
    "redis.googleapis.com",
    "aiplatform.googleapis.com",
    "containersecurity.googleapis.com",
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "dataplex.googleapis.com",
    "artifactregistry.googleapis.com",
    "storage-component.googleapis.com",
    "dataform.googleapis.com",
    "compute.googleapis.com",
    "datalineage.googleapis.com",
    "visionai.googleapis.com",
    "notebooks.googleapis.com",
    "dataflow.googleapis.com",
    "certificatemanager.googleapis.com",
  ]
}

variable "prefix" {
  type = string
}

variable "github_repository" {
  type        = string
  description = "GitHubリポジトリ名（例: owner/repo）"
}
