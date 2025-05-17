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
          image = "gcr.io/${var.project_id}/go-server-demo:v2"
          port {
            container_port = 8080
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
