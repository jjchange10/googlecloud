resource "google_project_service" "project_services" {
  project  = var.base_project_id
  for_each = toset(var.project_services_list)
  service  = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy = false
}
