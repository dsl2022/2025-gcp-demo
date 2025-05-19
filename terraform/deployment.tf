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
        }
      }
    }
  }
   timeouts {
    create = "5m"
    update = "5m"
  }
}
