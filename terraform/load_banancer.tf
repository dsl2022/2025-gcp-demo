resource "kubernetes_service" "go_server_demo" {
  metadata {
    name = "go-server-demo-service"
  }

  spec {
    selector = {
      app = "go-server-demo"
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}
