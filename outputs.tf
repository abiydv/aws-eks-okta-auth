output "oidc_id" {
  description = "Cluster name and identity provider configuration name separated by a colon"
  value = aws_eks_identity_provider_config.idp.id
}

output "oidc_status" {
  description = "Status of the EKS identity provider configuration - ACTIVE, CREATING or DELETING"
  value = aws_eks_identity_provider_config.idp.status
}
