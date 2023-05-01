variable "cluster_name" {
  description = "The cluster name."
  default     = "devops"
}

variable "helm_namespace" {
  description = "The namespace Helm will install the chart under"
  default = "logging"
}

variable "helm_release" {
  default     = "fluent"
  description = "The name of the Helm release"
}

variable "helm_repository" {
  default     = "https://fluent.github.io/helm-charts"
  description = "The repository where the Helm chart is stored"
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
variable "chart_version" {
  description = "Version of the Helm chart"
  default = "0.25.0"
}

variable "values" {
  default     = ""
  type        = string
  description = "Values to be passed to the Helm chart"
}

variable "region" {
  description = "The region name."
  default     = "eu-east-1"
}

variable "team" {
  description = "The team name."
  default     = "avengers"
}

variable "level" {
  description = "The level name."
  default     = "dev"
}
