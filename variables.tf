variable "cluster_name" {
  description = "Name given to the Kubernetes cluster, and prefixed to some resource tags"
  type        = string
}

variable "cluster_email" {
  description = "Email/Username of Kubernetes cluster owner"
  type        = string
  default     = null
}

variable "idp_client_id" {
  description = "Client ID as shared by the Identity provider"
  type        = string
}

variable "idp_config_name" {
  description = "Friendly name for this Identity provider config"
  type        = string
  default     = "idp"
}

variable "idp_issuer_url" {
  description = "Issuer url as shared by the Identity provider"
  type        = string
}

variable "idp_group_claim" {
  description = "Group claims provided by the Identity provider"
  type        = string
  default     = "groups"
}

variable "idp_group_prefix" {
  description = "Group prefix for k8s cluster group name"
  type        = string
  default     = "oidc:"
}

variable "idp_username_claim" {
  description = "Username claim provided by the Identity provider"
  type        = string
  default     = "preferred_username"
}

variable "idp_username_prefix" {
  description = "Username prefix for k8s cluster username"
  type        = string
  default     = "oidc:"
}

variable "idp_cluster_admin_groups" {
  description = "Groups on Identity provider which should have cluster admin access"
  type        = list(string)
  default     = []
}

variable "idp_cluster_admin_users" {
  description = "Users on Identity provider which should have cluster admin access"
  type        = list(string)
  default     = []
}

variable "idp_cluster_readonly_groups" {
  description = "Groups on Identity provider which should have cluster readonly access"
  type        = list(string)
  default     = []
}

variable "idp_cluster_readonly_users" {
  description = "Users on Identity provider which should have cluster readonly access"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to AWS resources created by this Terraform configuration"
  type        = map(any)
}
