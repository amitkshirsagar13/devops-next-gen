variable "kind_cluster_name_devops" {
  type        = string
  description = "The name of the devops cluster."
  default     = "devops"
}

variable "kind_cluster_name" {
  type        = string
  description = "The name of the cluster."
  default     = "dev"
}

variable "kind_cluster_config_path" {
  type        = string
  description = "The location where this cluster's kubeconfig will be saved to."
  default     = "~/.kube/config"
}
