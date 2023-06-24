locals {
  # default groups if no groups provided
  admins_groups = {
    "DEFAULT" : ["DevClusterAdmins"]
    "DEV"     : ["DevClusterAdmins", "ClusterAdmins"],
    "PROD"    : ["ProdClusterAdmins", "ClusterAdmins"]
  }
  readonly_groups = {
    "DEFAULT": ["DevClusterReadOnly"]
    "DEV"    : ["DevClusterReadOnly"],
    "PROD"   : ["ProdClusterReadOnly"]
  }
  cluster_readonly_users = compact(
    distinct(
      concat(
        [var.cluster_email],
        var.idp_cluster_readonly_users
      )
    )
  )
  cluster_readonly_groups = compact(
    distinct(
      concat(
        lookup(
          local.readonly_groups,
          upper(
            lookup(
              var.tags,
              "Environment",
              "Default"
            )
          ),
          lookup(
            local.readonly_groups,
            upper("Default")
          )
        ),
        var.idp_cluster_readonly_groups
      )
    )
  )
  cluster_admin_users = compact(
    distinct(
      concat(
        [var.cluster_email],
        var.idp_cluster_admin_users
      )
    )
  )
  cluster_admin_groups = compact(
    distinct(
      concat(
        lookup(
          local.admins_groups,
          upper(
            lookup(
              var.tags,
              "Environment",
              "Default"
            )
          ),
          lookup(
            local.admins_groups,
            upper("Default")
          )
        ),
        var.idp_cluster_admin_groups
      )
    )
  )
}


# Add new Identity provider to the cluster. This may take approx 20-30 mins to complete.
resource "aws_eks_identity_provider_config" "idp" {
  cluster_name = var.cluster_name
  oidc {
    client_id                     = var.idp_client_id
    identity_provider_config_name = var.idp_config_name
    issuer_url                    = var.idp_issuer_url
    groups_claim                  = var.idp_group_claim
    groups_prefix                 = var.idp_group_prefix
    username_claim                = var.idp_username_claim
    username_prefix               = var.idp_username_prefix
  }
}

# Apply cluster admin role bindings
resource "kubernetes_cluster_role_binding" "admins" {
  metadata {
    name = "oidc:admins"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  dynamic "subject" {
    # Don't add individual cluster admins on prod clusters
    for_each = lookup(var.tags, "Environment") == "prod" || length(local.cluster_admin_users) == 0 ? [] : local.cluster_admin_users
    content {
      kind      = "User"
      name      = "${var.idp_username_prefix}${subject.value}"
      api_group = "rbac.authorization.k8s.io"
    }
  }
  dynamic "subject" {
    for_each = local.cluster_admin_groups
    content {
      kind      = "Group"
      name      = "${var.idp_group_prefix}${subject.value}"
      api_group = "rbac.authorization.k8s.io"
    }
  }
}


# Apply cluster read-only role 
resource "kubernetes_cluster_role" "readonly" {
  metadata {
    name = "oidc:readonly"
  }

  rule {
    api_groups = ["", "extensions", "apps"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }
}

# Apply cluster read-only role bindings
resource "kubernetes_cluster_role_binding" "readonly" {
  metadata {
    name = "oidc:readonly"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "custom:readonly"
  }
  dynamic "subject" {
    for_each = length(local.cluster_readonly_users) == 0 ? [] : local.cluster_readonly_users
    content {
      kind      = "User"
      name      = "${var.idp_username_prefix}${subject.value}"
      api_group = "rbac.authorization.k8s.io"
    }
  }
  dynamic "subject" {
    for_each = local.cluster_readonly_groups
    content {
      kind      = "Group"
      name      = "${var.idp_group_prefix}${subject.value}"
      api_group = "rbac.authorization.k8s.io"
    }
  }
}
