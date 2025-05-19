resource "kubernetes_service" "go_server_demo" {
  metadata {
    name = "go-server-demo-service"
  }

  spec {
    selector = {
      app = "go-server-demo"
    }

    port {
      port        = 50051
      target_port = 50051
    }

    type = "LoadBalancer"
  }
}
