resource "time_sleep" "wait_5_seconds" {
  create_duration = "5s"
  triggers = {
    kube_config         = var.kind_cluster_config_path
    kube_context_devops = module.kind-devops.cluster_context
    kube_context_dev    = module.kind-dev.cluster_context
  }
  depends_on = [
    null_resource.kube-config-devops, 
    null_resource.kube-config-dev
  ]
}

module "kind-devops" {
  source = "./kind-devops"
  kind_cluster_name = var.kind_cluster_name_devops
  kind_cluster_config_path = var.kind_cluster_config_path
}

resource "null_resource" "kube-config-devops" {
  provisioner "local-exec" {
      command = <<EOF
        pwd
      EOF
    interpreter = ["sh", "-c"]
  }
  depends_on = [module.kind-devops]
}

provider "kubernetes" {
  alias             = "devops"
  config_path       = pathexpand(time_sleep.wait_5_seconds.triggers["kube_config"])
  config_context    = time_sleep.wait_5_seconds.triggers["kube_context_devops"]
}

provider "helm" {
  alias = "devops"
  kubernetes {
    config_path     = pathexpand(time_sleep.wait_5_seconds.triggers["kube_config"])
    config_context  = time_sleep.wait_5_seconds.triggers["kube_context_devops"]
  }
}

provider "kubectl" {
  alias = "devops"
  load_config_file  = true
  config_path       = pathexpand(time_sleep.wait_5_seconds.triggers["kube_config"])
  config_context    = time_sleep.wait_5_seconds.triggers["kube_context_devops"]
}

module "ns-devops" {
  source = "./ns"
  namespaces = ["echo", "vault"]
  providers = {
    kubernetes = kubernetes.devops
  }
  depends_on = [time_sleep.wait_5_seconds]
}

module "vault" {
  source = "./consul-vault"
  providers = {
    kubernetes = kubernetes.devops
    kubectl = kubectl.devops
    helm = helm.devops
  }
  depends_on = [module.ns-devops]
}

module "prometheus-devops" {
  source = "./prometheus"
  providers = {
    kubernetes = kubernetes.devops
    kubectl = kubectl.devops
    helm = helm.devops
  }
  depends_on = [time_sleep.wait_5_seconds]
}

module "nginx-devops" {
  source = "./nginx"
  providers = {
    kubernetes = kubernetes.devops
    kubectl = kubectl.devops
    helm = helm.devops
  }
  cluster_context = module.kind-devops.cluster_context
  node_http_port  = 32080
  node_https_port = 443
  depends_on = [module.prometheus-devops]
}

# ---------------------------------------------------------------------

module "kind-dev" {
  source = "./kind-dev"
  kind_cluster_name = var.kind_cluster_name_dev
  kind_cluster_config_path = var.kind_cluster_config_path
  depends_on = [module.kind-devops]
}

resource "null_resource" "kube-config-dev" {
  provisioner "local-exec" {
      command = <<EOF
        pwd
      EOF
    interpreter = ["sh", "-c"]
  }
  depends_on = [module.kind-dev]
}

provider "kubernetes" {
  alias             = "dev"
  config_path       = pathexpand(time_sleep.wait_5_seconds.triggers["kube_config"])
  config_context    = time_sleep.wait_5_seconds.triggers["kube_context_dev"]
}

provider "helm" {
  alias = "dev"
  kubernetes {
    config_path     = pathexpand(time_sleep.wait_5_seconds.triggers["kube_config"])
    config_context  = time_sleep.wait_5_seconds.triggers["kube_context_dev"]
  }
}

provider "kubectl" {
  alias = "dev"
  load_config_file  = true
  config_path       = pathexpand(time_sleep.wait_5_seconds.triggers["kube_config"])
  config_context    = time_sleep.wait_5_seconds.triggers["kube_context_dev"]
}

module "ns-dev" {
  source = "./ns"
  namespaces = ["echo"]
  providers = {
    kubernetes = kubernetes.dev
  }
  depends_on = [time_sleep.wait_5_seconds]
}

module "prometheus-dev" {
  source = "./prometheus"
  providers = {
    kubernetes = kubernetes.dev
    kubectl = kubectl.dev
    helm = helm.dev
  }
  depends_on = [module.ns-dev]
}

module "nginx-dev" {
  source = "./nginx"
  providers = {
    kubernetes = kubernetes.dev
    kubectl = kubectl.dev
    helm = helm.dev
  }
  cluster_context = module.kind-dev.cluster_context
  node_http_port  = 80
  node_https_port = 32443
  depends_on = [module.prometheus-dev]
}

# module "fluent" {
#   source = "./fluent"
#   depends_on = [module.nginx]
# }
