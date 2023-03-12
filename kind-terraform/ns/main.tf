resource "kubernetes_namespace" "ns" {
  for_each = toset(var.namespaces)
  metadata {
    name = each.key
  }
}