provider "kubernetes" {
    config_path = "~/.kube/config"
}

provider "helm" {
    kubernetes {
      config_path = "~/.kube/config"
    }
    debug = true
}

#We're only creating the dnsmasq claim, because we
#assume that the pihole one was created via migration
resource "kubernetes_persistent_volume_claim" "dnsmasq" {
    metadata {
        name = "pvc-dnsmasq"
        namespace = "pihole"
    }

    spec {
        access_modes = ["ReadWriteOnce"]
        resources {
            requests = {
                storage = "5Gi"
            }
        }

        storage_class_name = "longhorn"
    }
}

resource "kubernetes_pod" "pihole_pod"{
    metadata {
        name = "pihole"
        namespace = "pihole"
        labels = {
            app = "pihole"
        }
    }

    spec {
        dns_policy = "None"
        dns_config {
            nameservers = ["1.1.1.1"]
        }

        node_selector = {
            "kubernetes.io/hostname" = "gaming-pc-node"
        }

        container {
            name = "pihole"
            image = "pihole/pihole"
            
            env {
                name = "TZ"  
                value = var.timezone
            }
            env {
                name = "WEBPASSWORD" 
                value = var.web_password
            }

            security_context {
                privileged = true
            }

            port {
                container_port = "53"
                protocol = "UDP"
                host_port = "53"
            }

            port {
                container_port = "53"
                protocol = "TCP"
                host_port = "53"
            }


            volume_mount {
                name = "pvc-pihole"
                mount_path = "/etc/pihole"
            }

            volume_mount {
                name = "pvc-dnsmasq"
                mount_path = "/etc/dnsmasq.d"
            }

        }

        volume {
            name = "pvc-pihole"
            persistent_volume_claim {
                 claim_name = "pvc-pihole"
            }
        }

        volume {
            name = "pvc-dnsmasq"
            persistent_volume_claim {
                claim_name = "pvc-dnsmasq"
            } 
        }
    }
}

resource "kubernetes_service_v1" "pihole-service" {
    metadata {
        name = "pihole-frontend"
        namespace = "pihole"
    }

    spec {
        selector = {
            app = "pihole"
        }

        port {
            port = 80
            target_port = 80
            name = "http"
        }
    }
}

# resource "kubernetes_service_v1" "pihole-dns-service" {
#     metadata {
#         name = "pihole-dns"
#         namespace = "pihole"
#     }

#     spec {
#         selector = {
#             app = "pihole"
#         }

#         port {
#             port = 53
#             target_port = 53
#             name = "dns"
#         }

#         type = "LoadBalancer"
#     }
# }

resource "kubernetes_ingress_v1" "pihole_ingress" {
  metadata {
    namespace = "pihole"
    name = "pihole-ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/admin/$2"
    }
  }

  spec {            
    ingress_class_name = "nginx"

    rule{
        http{
            path{
                path = "/pihole(/|$)(.*)"
                path_type = "Prefix"
                
                backend {
                    service{
                        name = "pihole-frontend"
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



