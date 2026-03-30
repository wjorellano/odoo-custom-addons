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

resource "google_cloudbuild_trigger" "odoo_custom_trigger" {
  name        = "odoo-github-deploy"
  description = "Despliegue automático de módulos personalizados"
  location    = "us-central1" # Cámbialo si tu clúster está en otra región

  repository_event_config {
    # Este es el ID de la conexión de 2da generación
    repository = "projects/votos-app-99/locations/us-central1/connections/github-conn/repositories/odoo-custom-addons"
    push {
      branch = "^master$"
    }
  }

  filename = "cloudbuild.yaml"
}
