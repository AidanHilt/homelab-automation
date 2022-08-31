provider "kubernetes" {
    config_path = "~/.kube/config"
}

provider "helm" {
    kubernetes {
      config_path = "~/.kube/config"
    }
    debug = true
}

resource "helm_release" "calibre-web" {
    name = "prometheus-operator"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart = "kube-prometheus-stack"   


    namespace = var.namespace
}