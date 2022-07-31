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
# resource "kubernetes_persistent_volume_claim" "dnsmasq" {
#     metadata {
#         name = "pvc-dnsmasq"
#         namespace = "pihole"
#     }

#     spec {
#         access_modes = ["ReadWriteOnce"]
#         resources {
#             requests = {
#                 storage = "5Gi"
#             }
#         }

#         storage_class_name = "longhorn"
#     }
# }

resource "helm_release" "pihole" {
    name = "pihole"
    repository = "https://mojo2600.github.io/pihole-kubernetes/"
    chart = "pihole"
    
    namespace = "pihole"
    create_namespace = true

    values = [
        "${file("values.yaml")}"
    ]

}

# resource "kubernetes_pod" "pihole_pod"{
#     metadata {
#         name = "pihole"
#         namespace = "pihole"
#         labels = {
#             app = "pihole"
#         }
#     }

#     spec {
#         host_network = true
#         dns_policy = "None"
#         dns_config {
#             nameservers = ["1.1.1.1"]
#         }

#         container {
#             name = "pihole"
#             image = "pihole/pihole"
            
#             env {
#                 name = "TZ"  
#                 value = var.timezone
#             }
#             env {
#                 name = "WEBPASSWORD" 
#                 value = var.web_password
#             }

#             security_context {
#                 privileged = true
#             }

#             port {
#                 container_port = "53"
#                 protocol = "TCP"
#             }

#             port {
#                 container_port = "53"
#                 protocol = "UDP"
#             }

#             port {
#                 container_port = "67"
#                 protocol = "UDP"
#             }


#             volume_mount {
#                 name = "pvc-pihole"
#                 mount_path = "/etc/pihole"
#             }

#             volume_mount {
#                 name = "pvc-dnsmasq"
#                 mount_path = "/etc/dnsmasq.d"
#             }

#         }

#         volume {
#             name = "pvc-pihole"
#             persistent_volume_claim {
#                  claim_name = "pvc-pihole"
#             }
#         }

#         volume {
#             name = "pvc-dnsmasq"
#             persistent_volume_claim {
#                 claim_name = "pvc-dnsmasq"
#             } 
#         }
#     }
# }

# resource "kubernetes_service_v1" "pihole-service" {
#     metadata {
#         name = "pihole-frontend"
#         namespace = "pihole"
#     }

#     spec {
#         selector = {
#             app = "pihole"
#         }

#         port {
#             port = 80
#             target_port = 80
#             name = "http"
#         }
#     }
# }

# resource "kubernetes_ingress_v1" "pihole_ingress" {
#   metadata {
#     namespace = "pihole"
#     name = "pihole-ingress"
#     annotations = {
#       "kubernetes.io/ingress.class" = "nginx"
#       "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
#       "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
#     }
#   }

#   spec {            
#     ingress_class_name = "nginx"

#     rule{
#         http{
#             path{
#                 path = "/"
#                 path_type = "Prefix"
                
#                 backend {
#                     service{
#                         name = "pihole-frontend"
#                         port{
#                             number = 80
#                         }
#                     }
#                 }
#             }
#         }
#     }
#   }
# }



