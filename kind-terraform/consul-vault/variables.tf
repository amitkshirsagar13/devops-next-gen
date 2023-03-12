
variable "helm_namespace" {
  description = "The nginx ingress namespace (it will be created if needed)."
  default     = "vault"
}

variable "helm_repository" {
  default     = "https://helm.releases.hashicorp.com"
  description = "The repository where the Helm chart is stored"
}

variable "helm_release_consul" {
  default     = "consul"
  description = "The name of the Helm release"
}

variable "chart_version_consul" {
  type        = string
  description = "The Helm version for the nginx ingress controller."
  default     = "1.0.4"
}

variable "helm_release_vault" {
  default     = "vault"
  description = "The name of the Helm release"
}

variable "chart_version_vault" {
  type        = string
  description = "The Helm version for the nginx ingress controller."
  default     = "0.23.0"
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
