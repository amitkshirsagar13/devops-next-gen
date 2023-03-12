resource "tls_private_key" "acme_ca" {
  algorithm = "RSA"
  rsa_bits  = "2048"
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
    organizational_unit = "DevOps"
    country             = "US"
    locality            = "Troy"
    province            = "Michigan"
    postal_code         = "48084"
  }

  validity_period_hours = 175200

  allowed_uses = [
    "cert_signing", "key_encipherment", "server_auth", "client_auth"
  ]
}

resource "local_file" "acme_ca_cert" {
  content  = "${tls_self_signed_cert.acme_ca.cert_pem}"
  filename = "${path.module}/certs/acme_ca.pem"
}

resource "tls_private_key" "devops_next_genx" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "local_file" "devops_next_genx_key" {
  content  = "${tls_private_key.devops_next_genx.private_key_pem}"
  filename = "${path.module}/certs/devops_next_genx_private_key.pem"
}

resource "tls_cert_request" "devops_next_genx" {
  private_key_pem = "${tls_private_key.devops_next_genx.private_key_pem}"

  dns_names = ["devops-next.local","vault","vault.vault.svc.devops-next.localtest.me","vault.vault.svc","localhost","127.0.0.1"]
  ip_addresses = ["127.0.0.1"]
  subject {
    common_name         = "DevOps Next GenX CA"
    organization        = "DevOps Next GenX"
    organizational_unit = "DevOps"
    country             = "US"
    locality            = "Troy"
    province            = "Michigan"
    postal_code         = "48084"
  }
}

resource "tls_locally_signed_cert" "devops_next_genx" {
  cert_request_pem   = "${tls_cert_request.devops_next_genx.cert_request_pem}"
  ca_private_key_pem = "${tls_private_key.acme_ca.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.acme_ca.cert_pem}"

  validity_period_hours = 175200

  allowed_uses = [
    "cert_signing", "key_encipherment", "server_auth", "client_auth"
  ]
}

resource "local_file" "devops_next_genx_cert_pem" {
  content  = "${tls_locally_signed_cert.devops_next_genx.cert_pem}"
  filename = "${path.module}/certs/devops_next_genx_cert.pem"
}

resource "null_resource" "wait_for_certs" {
  triggers = {
    key = uuid()
    cert_path = "${path.module}/certs"
  }

  provisioner "local-exec" {
    command = <<EOF
      ls -ltr ${path.module}/certs
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
    "tls.crt" = file("${null_resource.wait_for_certs.triggers.cert_path}/devops_next_genx_cert.pem")
    "tls.key" = file("${null_resource.wait_for_certs.triggers.cert_path}/devops_next_genx_private_key.pem")
  }

  type = "kubernetes.io/tls"
}

resource "kubernetes_secret" "acme" {
  metadata {
    name = "tls-ca"
    namespace = "vault"
  }
  
  data = {
    "tls.crt" = file("${null_resource.wait_for_certs.triggers.cert_path}/acme_ca.pem")
    "tls.key" = file("${null_resource.wait_for_certs.triggers.cert_path}/acme_ca_private_key.pem")
  }

  type = "kubernetes.io/tls"
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

# locals {
#   crds_split_doc  = split("---", file("${path.module}/vault-ingress.yaml"))
#   crds_valid_yaml = [for doc in local.crds_split_doc : doc if try(yamldecode(doc).metadata.name, "") != ""]
#   crds_dict       = { for doc in toset(local.crds_valid_yaml) : yamldecode(doc).metadata.name => doc }
# }

# resource "kubectl_manifest" "crds" {
#   for_each  = local.crds_dict
#   yaml_body = each.value
#   depends_on = [ helm_release.vault ]
# }