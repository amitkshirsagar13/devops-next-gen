resource "helm_release" "ingress_nginx" {
  repository = var.helm_repository
  chart      = "ingress-nginx"
  name       = var.helm_release
  version    = var.chart_version

  namespace = var.helm_namespace
  create_namespace = true

  values = [file("./nginx/nginx-values.yaml")]

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
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s
    EOF
  }

  depends_on = [helm_release.ingress_nginx]
}