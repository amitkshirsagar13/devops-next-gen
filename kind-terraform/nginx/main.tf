resource "helm_release" "ingress_nginx" {
  repository = var.helm_repository
  chart      = "ingress-nginx"
  name       = var.helm_release
  version    = var.chart_version

  namespace = var.helm_namespace
  create_namespace = true

  values = [file("${path.module}/nginx-values.yaml")]
}

resource "null_resource" "wait_for_ingress_nginx" {
  triggers = {
    key = uuid()
    kube_config = var.kind_cluster_config_path
  }

  provisioner "local-exec" {
    command = <<EOF
      printf "\nWaiting for the nginx ingress controller...\n"
      kubectl wait --namespace ${helm_release.ingress_nginx.namespace} \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s
    EOF
  }

  depends_on = [helm_release.ingress_nginx]
}

# data "kubectl_filename_list" "manifests" {
#     pattern = "${path.module}/echo/*.yaml"
# }

# data "kubectl_file_documents" "manifests" {
#     content = "${path.module}/echo-service.yaml"
# }

# resource "kubernetes_manifest" "echo" {
#   # count = length(data.kubectl_filename_list.manifests.matches)
#   count     = length(data.kubectl_file_documents.manifests.documents)
#   manifest = yamldecode(element(data.kubectl_file_documents.manifests.documents, count.index))
#   depends_on = [ data.kubectl_file_documents.manifests ]
# }

locals {
  crds_split_doc  = split("---", file("${path.module}/echo-service.yaml"))
  crds_valid_yaml = [for doc in local.crds_split_doc : doc if try(yamldecode(doc).metadata.name, "") != ""]
  crds_dict       = { for doc in toset(local.crds_valid_yaml) : yamldecode(doc).metadata.name => doc }
}

resource "kubectl_manifest" "crds" {
  for_each  = local.crds_dict
  yaml_body = each.value
  depends_on = [ null_resource.wait_for_ingress_nginx ]
}