locals {
  config  = yamldecode(file("${path.module}/api-values.yaml"))
  template_vars = {
    slackApiUrl = local.config.slack.api_url
    cluster_name = var.cluster_name
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name = var.helm_release

  repository          = var.helm_repository
  repository_username = var.helm_repository_username
  repository_password = var.helm_repository_password

  chart     = "kube-prometheus-stack"
  version   = var.chart_version
  
  namespace = var.helm_namespace
  create_namespace = true

  timeout   = 1200
  
  # Default Configuration items
  set {
    name  = "slackApiUrl"
    value = local.config.slack.api_url
  }

  values = [
    templatefile("${path.module}/prometheus-values.yaml", local.template_vars)
  ]
}

locals {
  crds_split_doc  = split("---", file("${path.module}/prometheus-ingress.yaml"))
  crds_valid_yaml = [for doc in local.crds_split_doc : doc if try(yamldecode(templatefile(doc, local.template_vars)).metadata.name, "") != ""]
  crds_dict       = { for doc in toset(local.crds_valid_yaml) : yamldecode(templatefile(doc, local.template_vars)).metadata.name => doc }
}

resource "kubectl_manifest" "crds" {
  for_each  = local.crds_dict
  yaml_body = each.value
  depends_on = [ helm_release.kube_prometheus_stack ]
}