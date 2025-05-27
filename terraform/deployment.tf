resource "kubernetes_secret" "oauth_client" {
  metadata {
    name      = "oauth-client"
    namespace = "default"
  }

  data = {
    # Terraform variables or GitHub Actions secrets -> tfvars -> Terraform
    client_id = var.oauth_client_id  
  }
}


resource "kubernetes_deployment" "go_server_demo" {
  metadata {
    name = "go-server-demo"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "go-server-demo"
      }
    }

    template {
      metadata {
        labels = {
          app = "go-server-demo"
        }
      }

      spec {
        container {
          name  = "go-server-demo"
          image = var.image
          port {
            container_port = 50051
          }
          env {
            name = "GOOGLE_OAUTH_CLIENT_ID"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.oauth_client.metadata[0].name
                key  = "client_id"
              }
            }
          }
        }
      }
    }
  }
   timeouts {
    create = "5m"
    update = "5m"
  }
}
