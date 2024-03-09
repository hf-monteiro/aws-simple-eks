# Define an EKS cluster module with specific version and source path. 
# Cluster subnets are specified for both public and private access across multiple availability zones.
module "eks-cluster" {
    source = "git@gitlab.com:exp/exp-infra-modules.git//exp-eks?ref=tags/v1.7.7"
    cluster_subnet_ids = [module.vpc.public-subnets["us-east-1a"].id, module.vpc.public-subnets["us-east-1b"].id, module.vpc.public-subnets["us-east-1c"].id, module.vpc.private-subnets["us-east-1a"].id, module.vpc.private-subnets["us-east-1b"].id, module.vpc.private-subnets["us-east-1c"].id]
    public_access = true # Enable public access to the EKS cluster.
    public_cidrs = ["${chomp(data.http.myip.response_body)}/32", "11.11.11.11/32", "22.22.22.22/32", "33.33.33.33/32", "44.44.44.44/32", "55.55.55.55/32"] # Specify public CIDRs for access control.
    cluster_name = var.cluster-name # Set the cluster name from a variable.
    worker_subnet_ids = [module.vpc.private-subnets["us-east-1a"].id, module.vpc.private-subnets["us-east-1b"].id, module.vpc.private-subnets["us-east-1c"].id] # Define subnets for worker nodes, restricted to private subnets.
}

# Create an IAM role for OIDC with a specific policy for authentication.
resource "aws_iam_role" "oid-role" {
    assume_role_policy = data.aws_iam_policy_document.exp-oid-policy.json
    name = "oid-role"
}

# Create an IAM role for Secrets Manager with inline policy for accessing secrets.
resource "aws_iam_role" "sm-role" {
    assume_role_policy = data.aws_iam_policy_document.exp-oid-policy.json
    name = "sm-role"
    inline_policy {
        name = "allow-access-to-secrets"
        policy = data.aws_iam_policy_document.secrets-manager-policy.json
    }
}

# Define a module for creating an IAM role specifically for service accounts in EKS that require access to AWS resources.
# This role is configured to attach a policy for external secrets and define OIDC providers for authentication.
module "external_secrets_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.28.0"

  role_name = "external-secrets" # Name of the IAM role.

  attach_external_secrets_policy = true # Automatically attach a policy for external secrets access.

  oidc_providers = {
    main = {
      provider_arn               = module.eks-cluster.oidc-arn # Reference the OIDC provider ARN from the EKS cluster module.
      namespace_service_accounts = ["external-secrets:external-secrets"] # Specify the namespace and service account names that will use this role.
    }
  }
}
