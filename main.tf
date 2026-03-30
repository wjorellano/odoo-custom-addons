provider "google" {
  project = "votos-app-99"
  region  = "us-central1"
}

data "google_project" "project" {}

resource "google_project_iam_member" "cloudbuild_gke_admin" {
  project = data.google_project.project.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_cloudbuild_trigger" "odoo_custom_trigger" {
  name        = "odoo-github-deploy"
  description = "Despliegue automatico de modulos personalizados"
  project     = "votos-app-99"
  location    = "global"

  # Cambiamos 'github' por 'trigger_template' si el anterior falla
  # El nombre del repo lo sacas de la consola de GCP (Manage Repositories)
  trigger_template {
    branch_name = "master"
    repo_name   = "github_wjorellano_odoo-custom-addons"
  }

  filename = "cloudbuild.yaml"
}
