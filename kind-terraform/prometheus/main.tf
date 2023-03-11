locals {
  config  = yamldecode(file("${path.module}/api-values.yaml"))
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
    templatefile("./prometheus/prometheus-values.yaml", 
    { 
      slackApiUrl = local.config.slack.api_url 
    })
  ]
}