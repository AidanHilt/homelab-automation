provider "kubernetes" {
    config_path = "~/.kube/config"
}

provider "helm" {
    kubernetes {
      config_path = "~/.kube/config"
    }
    debug = true
}

resource "kubernetes_persistent_volume_claim" "calibre-web-data" {
    metadata {
        name = "pvc-calibre-data"
        namespace = var.namespace
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


resource "helm_release" "calibre-web" {
    name = "prometheus-operator"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart = "kube-prometheus-stack"   


    namespace = var.namespace
}