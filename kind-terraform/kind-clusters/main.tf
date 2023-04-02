resource "kind_cluster" "devops" {
  name            = "devops"
  kubeconfig_path = pathexpand(var.kind_cluster_config_path)
  wait_for_ready  = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    networking {
      api_server_address  = "127.0.0.1"
      api_server_port     = 6443
      pod_subnet          = "10.110.0.0/16"
      service_subnet      = "10.115.0.0/16"
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
              system-reserved: memory=16Gi,cpu=6
        INTF
      ]
      extra_port_mappings {
        container_port = 80
        host_port      = 30080
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
      }
    }

    node {
      role = "worker"
    }
  }
}

resource "kind_cluster" "dev" {
  name            = var.kind_cluster_name
  kubeconfig_path = pathexpand(var.kind_cluster_config_path)
  wait_for_ready  = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    networking {
      api_server_address  = "127.0.0.1"
      api_server_port     = 8443
      pod_subnet          = "10.220.0.0/16"
      service_subnet      = "10.225.0.0/16"
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
              system-reserved: memory=16Gi,cpu=6
        INTF
      ]
      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 30443
      }
    }

    node {
      role = "worker"
    }

    node {
      role = "worker"
    }
  }
  depends_on = [kind_cluster.devops]
}

output "devops" {
  value = jsondecode(jsonencode(yamldecode(kind_cluster.devops.kubeconfig).contexts))[0].name
}

output "dev" {
  value = jsondecode(jsonencode(yamldecode(kind_cluster.dev.kubeconfig).contexts))[0].name
}
