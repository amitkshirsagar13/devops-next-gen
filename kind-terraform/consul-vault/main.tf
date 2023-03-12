resource "tls_private_key" "acme_ca" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "acme_ca_key" {
  content  = "${tls_private_key.acme_ca.private_key_pem}"
  filename = "${path.module}/certs/acme_ca_private_key.pem"
}

resource "tls_self_signed_cert" "acme_ca" {
  private_key_pem   = "${tls_private_key.acme_ca.private_key_pem}"
  is_ca_certificate = true

  subject {
    common_name         = "DevOps Next GenX CA"
    organization        = "DevOps Next GenX"
    organizational_unit = "devops"
  }

  validity_period_hours = 87659

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}

resource "local_file" "acme_ca_cert" {
  content  = "${tls_self_signed_cert.acme_ca.cert_pem}"
  filename = "${path.module}/certs/acme_ca.pem"
}

resource "tls_private_key" "devops_next_genx" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "devops_next_genx_key" {
  content  = "${tls_private_key.devops_next_genx.private_key_pem}"
  filename = "${path.module}/certs/devops_next_genx_private_key.pem"
}

resource "tls_cert_request" "devops_next_genx" {
  private_key_pem = "${tls_private_key.devops_next_genx.private_key_pem}"

  dns_names = ["localtest.me"]

  subject {
    common_name         = "localtest.me"
    organization        = "DevOps Next GenX"
    country             = "US"
    organizational_unit = "DevOps"
  }
}

resource "tls_locally_signed_cert" "devops_next_genx" {
  cert_request_pem   = "${tls_cert_request.devops_next_genx.cert_request_pem}"
  ca_private_key_pem = "${tls_private_key.acme_ca.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.acme_ca.cert_pem}"

  validity_period_hours = 87659

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

resource "local_file" "devops_next_genx_cert_pem" {
  content  = "${tls_locally_signed_cert.devops_next_genx.cert_pem}"
  filename = "${path.module}/certs/devops_next_genx_cert.pem"
}

resource "null_resource" "wait_for_sed" {
  triggers = {
    key = uuid()
  }

  provisioner "local-exec" {
    command = <<EOF
      sed ':a;N;$!ba;s/\n/\\n/g' ${path.module}/certs/acme_ca.pem
      sed ':a;N;$!ba;s/\n/\\n/g' ${path.module}/certs/acme_ca_private_key.pem
      sed ':a;N;$!ba;s/\n/\\n/g' ${path.module}/certs/devops_next_genx_cert.pem
      sed ':a;N;$!ba;s/\n/\\n/g' ${path.module}/certs/devops_next_genx_private_key.pem
    EOF
  }
  depends_on = [
    local_file.devops_next_genx_cert_pem, local_file.devops_next_genx_key, local_file.acme_ca_cert, local_file.acme_ca_key
  ]
}

resource "kubernetes_secret" "devops_next_genx" {
  metadata {
    name = "tls-server"
    namespace = "vault"
  }
  
  data = {
    "tls.crt" = "${path.module}/certs/devops_next_genx_cert.pem"
    "tls.key" = "${path.module}/certs/devops_next_genx_private_key.pem"
  }

  type = "kubernetes.io/tls"
  depends_on = [
    null_resource.wait_for_sed
  ]
}

resource "kubernetes_secret" "acme" {
  metadata {
    name = "tls-ca"
    namespace = "vault"
  }
  
  data = {
    "tls.crt" = "${path.module}/certs/acme_ca.pem"
    "tls.key" = "${path.module}/certs/acme_ca_private_key.pem"
  }

  type = "kubernetes.io/tls"
  depends_on = [
    null_resource.wait_for_sed
  ]
}

resource "helm_release" "consul" {
  repository = var.helm_repository
  chart      = "consul"
  name       = var.helm_release_consul
  version    = var.chart_version_consul

  namespace = var.helm_namespace
  create_namespace = true

  values = [file("${path.module}/consul-values.yaml")]
  depends_on = [
    kubernetes_secret.devops_next_genx
  ]
}

resource "helm_release" "vault" {
  repository = var.helm_repository
  chart      = "vault"
  name       = var.helm_release_vault
  version    = var.chart_version_vault

  namespace = var.helm_namespace
  create_namespace = true

  values = [file("${path.module}/vault-values.yaml")]
  depends_on = [
    helm_release.consul
  ]
}

locals {
  crds_split_doc  = split("---", file("${path.module}/vault-ingress.yaml"))
  crds_valid_yaml = [for doc in local.crds_split_doc : doc if try(yamldecode(doc).metadata.name, "") != ""]
  crds_dict       = { for doc in toset(local.crds_valid_yaml) : yamldecode(doc).metadata.name => doc }
}

resource "kubectl_manifest" "crds" {
  for_each  = local.crds_dict
  yaml_body = each.value
  depends_on = [ helm_release.vault ]
}