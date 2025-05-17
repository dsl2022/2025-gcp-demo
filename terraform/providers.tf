terraform {
  backend "gcs" {
    bucket = "gcp-demo-tf-state-bucket" 
    prefix = "terraform/state"
  }
  required_providers {
    
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"     # or "~> 5.0" if you want just the v5 line
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

data "google_client_config" "default" {}

provider "google" {
  credentials = file("../gcp-demo-460104-0ad938b2f7e9.json")
  project     = var.project_id 
  region      = "us-central1"  
}

resource "google_project_service" "cloudresourcemanager" {
  project = var.project_id 
  service = "cloudresourcemanager.googleapis.com"
}

# provider "kubernetes" {
#   host                   = google_container_cluster.primary.endpoint
#   cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
#   token                  = data.google_client_config.default.access_token
# }

provider "kubernetes" {
  host = "https://${google_container_cluster.primary.endpoint}"

  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  )
}