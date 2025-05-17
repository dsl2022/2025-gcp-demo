# resource "google_project_service" "cloudapis" {
#   project = var.project_id
#   service = "cloudapis.googleapis.com"
# }

# resource "google_project_service" "iam" {
#   project = var.project_id
#   service = "iam.googleapis.com"
#   depends_on = [google_project_service.cloudapis]
# }

# # Container must be destroyed BEFORE Compute
# resource "google_project_service" "container" {
#   project = var.project_id
#   service = "container.googleapis.com"
#   disable_dependent_services = true  # Allows disabling dependent services
#   depends_on = [google_project_service.iam]

#   lifecycle {
#     # Ensure container is destroyed before compute
#     create_before_destroy = false
#   }
# }

# # Compute should only be destroyed after Container is gone
# resource "google_project_service" "compute" {
#   project = var.project_id
#   service = "compute.googleapis.com"

#   # Explicitly depend on container to enforce destruction order
#   depends_on = [google_project_service.container]

#   lifecycle {
#     create_before_destroy = false
#     prevent_destroy = false
#   }
# }


resource "google_container_cluster" "primary" {
  name     = "gcp-demo-cluster"
  location = "us-central1-a"  # Specify the zone or region for the cluster
  deletion_protection = false
  initial_node_count = 3  # Number of nodes in the cluster

  node_config {
    machine_type = "e2-medium"  # Change based on your requirements
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
      cidr_block = "0.0.0.0/0"  # Allow all IPs, modify as needed
      display_name = "Global"
    }
  }
}
