provider "google" {
  project = "votos-app-99"
  region  = "us-central1"
}

data "google_project" "project" {}

# PERMISO 1: Para que Cloud Build pueda desplegar en GKE
resource "google_project_iam_member" "cloudbuild_gke_admin" {
  project = data.google_project.project.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

# PERMISO 2: Para que Cloud Build pueda leer/escribir en Artifact Registry
resource "google_project_iam_member" "cloudbuild_registry" {
  project = data.google_project.project.project_id
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

# Permiso para que la cuenta escriba logs (Soluciona el error de Logging)
resource "google_project_iam_member" "cloudbuild_logging" {
  project = "votos-app-99"
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:github-deploy@votos-app-99.iam.gserviceaccount.com"
}

# Permiso para que la cuenta maneje el clúster (Soluciona el error de kubectl)
resource "google_project_iam_member" "cloudbuild_gke_admin_custom" {
  project = "votos-app-99"
  role    = "roles/container.developer"
  member  = "serviceAccount:github-deploy@votos-app-99.iam.gserviceaccount.com"
}
