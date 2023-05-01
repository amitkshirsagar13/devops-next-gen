resource "helm_release" "fluentbit" {
  name = var.helm_release

  repository          = var.helm_repository
  repository_username = var.helm_repository_username
  repository_password = var.helm_repository_password

  chart     = "fluent-bit"
  version   = var.chart_version
  
  namespace = var.helm_namespace
  create_namespace = true

  timeout   = 1200

  values = [templatefile("${path.module}/fluentbit-values.yaml", {
      CLUSTER_NAME = "${var.cluster_name}",
      REGION       = "${var.region}",
      TEAM         = "${var.team}",
      LEVEL        = "${var.level}"
    })
  ]
}

locals {
  template_vars = {
    cluster_name = var.cluster_name
  }
  crds_split_doc  = split("---", templatefile("${path.module}/fluent-metrics-service.yaml", local.template_vars))
  crds_valid_yaml = [for doc in local.crds_split_doc : doc if try(yamldecode(doc).metadata.name, "") != ""]
  crds_dict       = { for doc in toset(local.crds_valid_yaml) : yamldecode(doc).metadata.name => doc }
}

resource "kubectl_manifest" "crds" {
  for_each  = local.crds_dict
  yaml_body = each.value
  depends_on = [ helm_release.fluentbit ]
}