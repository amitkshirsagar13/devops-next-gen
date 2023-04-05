resource "helm_release" "ingress_nginx" {
  repository = var.helm_repository
  chart      = "ingress-nginx"
  name       = var.helm_release
  version    = var.chart_version

  namespace = var.helm_namespace
  create_namespace = true

  values = [file("${path.module}/nginx-values.yaml")]
  
  set {
    name  = "controller.hostPort.ports.http"
    value = var.node_http_port
  }

  set {
    name  = "controller.hostPort.ports.https"
    value = var.node_https_port
  }
}

resource "null_resource" "wait_for_ingress_nginx" {
  triggers = {
    key = uuid()
  }

  provisioner "local-exec" {
    command = <<EOF
      printf "\nWaiting for the nginx ingress controller...\n"
      kubectl wait --namespace ${helm_release.ingress_nginx.namespace} \
        --for=condition=ready pod \
        --context=kind-${var.cluster_name} \
        --selector=app.kubernetes.io/component=controller \
        --timeout=180s
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
  crds_valid_yaml = [for doc in local.crds_split_doc : doc if try(yamldecode(templatefile(doc, {cluster_name = var.cluster_name})).metadata.name, "") != ""]
  crds_dict       = { for doc in toset(local.crds_valid_yaml) : yamldecode(templatefile(doc, {cluster_name = var.cluster_name})).metadata.name => doc }
}

resource "kubectl_manifest" "crds" {
  for_each  = local.crds_dict
  yaml_body = each.value
  depends_on = [ null_resource.wait_for_ingress_nginx ]
}