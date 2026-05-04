data "google_compute_default_service_account" "default" {
}

resource "google_project_iam_member" "compute_artifact_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}