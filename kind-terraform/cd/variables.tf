variable "cluster_name" {
  description = "The cluster name."
  default     = "devops"
}

variable "helm_namespace" {
  description = "The nginx ingress namespace (it will be created if needed)."
  default     = "nginx"
}

variable "helm_release" {
  default     = "ingress-nginx"
  description = "The name of the Helm release"
}

variable "helm_repository" {
  default     = "https://kubernetes.github.io/ingress-nginx"
  description = "The repository where the Helm chart is stored"
}

variable "chart_version" {
  type        = string
  description = "The Helm version for the nginx ingress controller."
  default     = "4.5.2"
}

variable "helm_repository_password" {
  type        = string
  nullable    = false
  default     = ""
  description = "The password of the repository where the Helm chart is stored"
  sensitive   = true
}

variable "helm_repository_username" {
  type        = string
  nullable    = false
  default     = ""
  description = "The username of the repository where the Helm chart is stored"
  sensitive   = true
}

variable "values" {
  default     = ""
  type        = string
  description = "Values to be passed to the Helm chart"
}

variable "node_http_port" {
  type        = string
  description = "Default http port"
  default     = 80
}

variable "node_https_port" {
  type        = string
  description = "Default https port"
  default     = 443
}