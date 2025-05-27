resource "google_container_cluster" "primary" {
  provider            = google-beta
  name     = "gcp-demo-cluster"
  location = "us-central1-a"  
  # deletion_protection = false
  initial_node_count = 3 
  deletion_protection = false
  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/userinfo.email"
    ]
  }

  # Enable the API server with Kubernetes RBAC
  enable_kubernetes_alpha = false

  # Set up a master authorized network (optional)
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "0.0.0.0/0" 
      display_name = "Global"
    }
  }
}
