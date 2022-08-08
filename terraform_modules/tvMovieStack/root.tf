provider "kubernetes" {
    config_path = "~/.kube/config"
}

provider "helm" {
    kubernetes {
      config_path = "~/.kube/config"
    }
    debug = true
}

resource "helm_release" "prometheus-operator" {
    name = "prometheus-operator"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart = "kube-prometheus-stack"   


    namespace = var.namespace
}

resource "kubernetes_persistent_volume" "data-volume" {
    metadata {
        name = "data-volume"
    }

    spec {
        capacity = {
            storage = "1000Gi"
        }

        storage_class_name = "manual"

        access_modes = ["ReadWriteMany"]
        persistent_volume_source {
            host_path {
                path = "/storagePool/videoData"
            }
        }
    }
}

resource "kubernetes_persistent_volume_claim" "data-pvc" {
    metadata {
        name = "data-pvc"
        namespace = var.namespace
    }

    spec {
        access_modes = ["ReadWriteMany"]

        resources {
            requests = {
                storage = "1000Gi"
            }
        }

        storage_class_name = "manual"

        volume_name = "data-volume"
    
    }

}


resource "helm_release" "prowlarr"{
    name = "prowlarr"
    repository = "https://k8s-at-home.com/charts/"
    chart = "prowlarr"

    values = [
        "${file("prowlarr-values.yaml")}"
    ]   

    timeout = 60

    namespace = var.namespace
}

resource "kubernetes_ingress_v1" "prowlarr_ingress" {
  metadata {
    namespace = var.namespace
    name = "prowlarr-ingress"
    annotations = {
    }
  }

  spec {            
    ingress_class_name = "nginx"

    rule{
        http{
            path{
                path = "/prowlarr(/|$)(.*)"
                path_type = "Prefix"
                
                backend {
                    service{
                        name = "prowlarr"
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

resource "helm_release" "sonarr"{
    name = "sonarr"
    repository = "https://k8s-at-home.com/charts/"
    chart = "sonarr"

    values = [
        "${file("sonarr-values.yaml")}"
    ]   

    timeout = 60

    namespace = var.namespace
}

resource "kubernetes_ingress_v1"  "sonarr_ingress" {
  metadata {
    namespace = var.namespace
    name = "sonarr-ingress"
    annotations = {
    }
  }

  spec {            
    ingress_class_name = "nginx"

    rule{
        http{
            path{
                path = "/sonarr(/|$)(.*)"
                path_type = "Prefix"
                
                backend {
                    service{
                        name = "sonarr"
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