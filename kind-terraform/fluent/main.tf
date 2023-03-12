resource "helm_release" "fluentd" {
  name = var.helm_release

  repository          = var.helm_repository
  repository_username = var.helm_repository_username
  repository_password = var.helm_repository_password

  chart     = "fluentd"
  version   = var.chart_version
  
  namespace = var.helm_namespace
  create_namespace = true

  timeout   = 1200
  
  values = [file("${path.module}/fluentd-values.yaml")]
}

locals {
  crds_split_doc  = split("---", file("${path.module}/fluent-metrics-service.yaml"))
  crds_valid_yaml = [for doc in local.crds_split_doc : doc if try(yamldecode(doc).metadata.name, "") != ""]
  crds_dict       = { for doc in toset(local.crds_valid_yaml) : yamldecode(doc).metadata.name => doc }
}

resource "kubectl_manifest" "crds" {
  for_each  = local.crds_dict
  yaml_body = each.value
  depends_on = [ helm_release.fluentd ]
}