module "kind-dev" {
  source = "./kind-dev"
  kind_cluster_name = var.kind_cluster_name
  kind_cluster_config_path = var.kind_cluster_config_path
}

resource "null_resource" "kube-config" {
  provisioner "local-exec" {
      command = <<EOF
        pwd
      EOF
    interpreter = ["sh", "-c"]
  }
  depends_on = [module.kind-dev]
}

resource "time_sleep" "wait_5_seconds" {
  create_duration = "5s"
  triggers = {
    kube_config = var.kind_cluster_config_path
  }
  depends_on = [null_resource.kube-config]
}

provider "kubernetes" {
  config_path = pathexpand(time_sleep.wait_5_seconds.triggers["kube_config"])
}

provider "helm" {
  kubernetes {
    config_path = pathexpand(time_sleep.wait_5_seconds.triggers["kube_config"])
  }
}

provider "kubectl" {
  load_config_file       = true
  config_path = pathexpand(time_sleep.wait_5_seconds.triggers["kube_config"])
}

module "ns" {
  source = "./ns"
  namespaces = ["echo", "vault"]
  depends_on = [time_sleep.wait_5_seconds]
}

module "prometheus" {
  source = "./prometheus"
  kind_cluster_config_path = var.kind_cluster_config_path
  depends_on = [time_sleep.wait_5_seconds]
}

module "nginx" {
  source = "./nginx"
  kind_cluster_config_path = var.kind_cluster_config_path
  depends_on = [module.prometheus]
}

module "fluent" {
  source = "./fluent"
  depends_on = [module.nginx]
}

module "vault" {
  source = "./consul-vault"
  depends_on = [time_sleep.wait_5_seconds]
}