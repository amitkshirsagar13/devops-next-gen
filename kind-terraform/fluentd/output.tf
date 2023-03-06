output "helm_namespace" {
  value = var.helm_namespace
}

output "helm_release" {
  value       = var.helm_release
  description = "The name of the Helm release. For use by external ServiceMonitors"
}