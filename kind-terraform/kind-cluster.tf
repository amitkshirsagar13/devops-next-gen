resource "kind_cluster" "default" {
  name            = var.kind_cluster_name
  kubeconfig_path = pathexpand(var.kind_cluster_config_path)
  wait_for_ready  = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    networking {
      api_server_address  = "127.0.0.1"
      api_server_port     = 6443
      pod_subnet          = "10.240.0.0/16"
      service_subnet      = "10.0.0.0/16"
      # disable_default_cni = true
    }
    
    node {
      role = "control-plane"

      kubeadm_config_patches = [
        <<-INTF
          kind: InitConfiguration
          nodeRegistration:
            kubeletExtraArgs:
              node-labels: "ingress-ready=true"
        INTF
      ]
      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
      }
    }

    node {
      role = "worker"
    }

    node {
      role = "worker"
    }

    node {
      role = "worker"
    }
  }
  
}

module "prometheus" {
  source = "./prometheus"
  depends_on = [kind_cluster.default]
}

module "nginx" {
  source = "./nginx"
  depends_on = [module.prometheus]
}

module "fluent" {
  source = "./fluent"
  depends_on = [module.nginx]
}