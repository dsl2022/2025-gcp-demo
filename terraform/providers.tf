provider "google" {
  credentials = file("../gcp-demo-460104-0ad938b2f7e9.json")
  project     = var.project_id 
  region      = "us-central1"  
}

resource "google_project_service" "cloudresourcemanager" {
  project = var.project_id 
  service = "cloudresourcemanager.googleapis.com"
}