provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "namespace" {
    metadata {
        name = var.namespace
    }
}

resource "kubernetes_daemonset" "nginx" {
  metadata {
    name      = "nginx-daemonset"
    namespace = var.namespace
    labels = {
      app = "nginx"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        name = "nginx"
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          image = "nginx:${var.nginx-version}"
          name  = "nginx"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "150m"
              memory = "25Mi"
            }
          }

          volume_mount {
            name = "nginx-configmap"
            mount_path = "/etc/nginx/nginx.conf"
            sub_path = "nginx.conf"
          }

              port {
                host_port = 32000
                container_port = 80
              }

              port {
                host_port = 32100
                container_port = 443
              }
        }

        volume {
          name = "nginx-configmap"
          config_map {
            name = "nginx-config"

            items {
              key = "nginx.conf"
              path = "nginx.conf"
              mode = "0444"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map_v1" "nginx-config" {
  metadata {
    name = "nginx-config"
    namespace = var.namespace
  }

  data = {
    "nginx.conf" = "${file("${path.module}/nginx.conf")}"
  }
}