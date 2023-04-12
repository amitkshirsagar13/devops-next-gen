module "kind-devops" {
  source = "./kind-clusters/devops"
  kind_cluster_name = var.kind_cluster_name_devops
  kind_cluster_config_path = var.kind_cluster_config_path
}

module "kind-dev" {
  source = "./kind-clusters/dev"
  kind_cluster_name = var.kind_cluster_name
  kind_cluster_config_path = var.kind_cluster_config_path
  depends_on = [module.kind-devops]
}

resource "null_resource" "kube-config" {
  provisioner "local-exec" {
      command = <<EOF
        pwd
      EOF
    interpreter = ["sh", "-c"]
  }
  depends_on = [
    # module.kind-devops,
    module.kind-dev
  ]
}

resource "time_sleep" "wait_5_seconds" {
  create_duration = "5s"
  triggers = {
    kube_config = var.kind_cluster_config_path
    kube_context_devops = module.kind-devops.context
    kube_context_dev    = module.kind-dev.context
  }
  depends_on = [null_resource.kube-config]
}

provider "kubernetes" {
  alias             = "devops"
  config_path       = pathexpand(time_sleep.wait_5_seconds.triggers["kube_config"])
  config_context    = time_sleep.wait_5_seconds.triggers["kube_context_devops"]
}

provider "helm" {
  alias             = "devops"
  kubernetes {
    config_path     = pathexpand(time_sleep.wait_5_seconds.triggers["kube_config"])
    config_context  = time_sleep.wait_5_seconds.triggers["kube_context_devops"]
  }
}

provider "kubectl" {
  alias             = "devops"
  load_config_file  = true
  config_path       = pathexpand(time_sleep.wait_5_seconds.triggers["kube_config"])
  config_context    = time_sleep.wait_5_seconds.triggers["kube_context_devops"]
}

provider "kubernetes" {
  alias             = "dev"
  config_path       = pathexpand(time_sleep.wait_5_seconds.triggers["kube_config"])
  config_context    = time_sleep.wait_5_seconds.triggers["kube_context_dev"]
}

provider "helm" {
  alias             = "dev"
  kubernetes {
    config_path     = pathexpand(time_sleep.wait_5_seconds.triggers["kube_config"])
    config_context  = time_sleep.wait_5_seconds.triggers["kube_context_dev"]
  }
}

provider "kubectl" {
  alias             = "dev"
  load_config_file  = true
  config_path       = pathexpand(time_sleep.wait_5_seconds.triggers["kube_config"])
  config_context    = time_sleep.wait_5_seconds.triggers["kube_context_dev"]
}

# ---------------------------------------------------------------------
# Devops Cluster Resources
# ---------------------------------------------------------------------

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
  cluster_name    = "devops"
  depends_on = [module.ns-devops]
}

module "cortex-devops" {
  source = "./observability/cortex"
  providers = {
    kubernetes = kubernetes.devops
    kubectl = kubectl.devops
    helm = helm.devops
  }
  cluster_name    = "devops"
  depends_on = [module.ns-devops]
}

module "nginx-devops" {
  source = "./nginx"
  providers = {
    kubernetes = kubernetes.devops
    kubectl = kubectl.devops
    helm = helm.devops
  }
  cluster_name    = "devops"
  node_http_port  = 32080
  node_https_port = 443
  depends_on = [module.cortex-devops]
}

# ---------------------------------------------------------------------
# Dev Cluster Resources
# ---------------------------------------------------------------------
module "ns-dev" {
  source = "./ns"
  namespaces = ["echo"]
  providers = {
    kubernetes = kubernetes.dev
  }
  depends_on = [time_sleep.wait_5_seconds]
}

module "prometheus-dev" {
  source = "./observability/prometheus"
  providers = {
    kubernetes = kubernetes.dev
    kubectl = kubectl.dev
    helm = helm.dev
  }
  cluster_name    = "dev"
  depends_on = [module.ns-dev]
}

module "nginx-dev" {
  source = "./nginx"
  providers = {
    kubernetes = kubernetes.dev
    kubectl = kubectl.dev
    helm = helm.dev
  }
  cluster_name    = "dev"
  node_http_port  = 80
  node_https_port = 32443
  depends_on = [
    module.prometheus-dev,
    module.nginx-devops
  ]
}

module "fluentbit" {
  source = "./observability/fluentbit"
  providers = {
    kubernetes = kubernetes.dev
    kubectl = kubectl.dev
    helm = helm.dev
  }
  cluster_name    = "dev"
  depends_on = [module.nginx-dev]
}