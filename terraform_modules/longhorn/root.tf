provider "kubernetes" {
    config_path = "~/.kube/config"
}

provider "helm" {
    kubernetes {
      config_path = "~/.kube/config"
    }
    debug = true
}

resource "helm_release" "longhorn"{
    name = "longhorn"
    repository = "https://charts.longhorn.io"
    chart = "longhorn"

    values = [
        "${file("values.yaml")}"
    ]

    namespace = "longhorn-system"
    create_namespace = true

    cleanup_on_fail = true
}

resource "kubernetes_secret" "longhorn_auth" {
  metadata {
    namespace = "longhorn-system"
    name = "basic-auth"
  }

  data = {
    "auth" = "${file("auth")}"
  }

  type = "kubernetes.io/generic"
}

resource "kubernetes_ingress_v1" "longhorn_ingress" {
  metadata {
    namespace = "longhorn-system"
    name = "longhorn-ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/auth-type" = "basic"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
      "nginx.ingress.kubernetes.io/auth-secret" = "basic-auth"
      "nginx.ingress.kubernetes.io/auth-realm" = "Authentication Required "
      "nginx.ingress.kubernetes.io/proxy-body-size"= "10000m"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
    }
  }

  spec {
    rule{
        http{
            path{
                path = "/longhorn(/|$)(.*)"
                path_type = "Prefix"
                
                backend {
                    service{
                        name = "longhorn-frontend"
                        port{
                            number = 80
                        }
                    }
                }
            }
        }
    }
  }
}