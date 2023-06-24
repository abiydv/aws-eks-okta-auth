# AWS EKS OKTA Auth
Authenticate to AWS EKS clusters with Okta

## Requirements

When using this module, ensure to provide the relevant aws, and kuberneters terraform providers

## Usage

1. Use this as a module to configure an additional oidc provider for the cluster - 
    ```
    module eks_oidc_idp {
    source = "git::ssh://git@github.com/abiydv/aws-eks-okta-auth.git?ref=v1.0.0"

    cluster_name       = "my-cluster"
    cluster_email      = "user"
    idp_client_id      = "client-id"
    idp_config_name    = "okta"
    idp_issuer_url     = "https://example.okta.com"
    idp_group_claim    = "groups"
    idp_username_claim = "username"
    idp_cluster_admin_groups    = ["okta-admins"]
    idp_cluster_admin_users     = ["user1", "user2"]
    idp_cluster_readonly_groups = ["okta-devs"]
    idp_cluster_readonly_users  = ["user3", "user4"]
    tags = var.tags
    }
    ```

2. Install the kubectl plugin [kubelogin](https://github.com/int128/kubelogin)

3. Add a new user config in `~/.kube/config` file -
    ```
    - name: okta
        user:
        exec:
            apiVersion: client.authentication.k8s.io/v1beta1
            args:
            - oidc-login
            - get-token
            - --oidc-issuer-url=https://okta.com/oauth2/
            - --oidc-client-id=clientid
            - --oidc-client-secret=clientsecret
            - --oidc-extra-scope=profile
            command: kubectl
            env: null
            provideClusterInfo: false
    ```

    After this change, a minimal `kubectl` config with 1 cluster, and 1 user might look like the following snippet - 

    ```
    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority-data: data
        server: https://cluster.us-west-1.eks.amazonaws.com
        name: eks-cluster
    contexts:
    - context:
        cluster: eks-cluster
        user: okta
        name: eks-cluster-okta-ctx
    users:
    - name: okta
        user:
        exec:
            apiVersion: client.authentication.k8s.io/v1beta1
            args:
            - oidc-login
            - get-token
            - --oidc-issuer-url=https://okta.com/oauth2/
            - --oidc-client-id=clientid
            - --oidc-client-secret=clientsecret
            - --oidc-extra-scope=profile
            - -v1
            command: kubectl
            env: null
            provideClusterInfo: false
    kind: Config
    preferences: {}
    current-context: eks-cluster-okta-ctx

    ```

4. Test access by running any `kubectl` command - 
    ```
    kubectl get svc
    ```
