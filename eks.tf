module "eks-cluster" {
    source = "git@gitlab.com:exp/exp-infra-modules.git//exp-eks?ref=tags/v1.7.7"
    cluster_subnet_ids = [module.vpc.public-subnets["us-east-1a"].id, module.vpc.public-subnets["us-east-1b"].id, module.vpc.public-subnets["us-east-1c"].id, module.vpc.private-subnets["us-east-1a"].id, module.vpc.private-subnets["us-east-1b"].id, module.vpc.private-subnets["us-east-1c"].id]
    public_access = true
    public_cidrs = ["${chomp(data.http.myip.response_body)}/32", "68.38.183.162/32", "75.70.120.9/32", "107.11.45.116/32", "23.114.171.37/32", "34.139.209.153/32"]
    cluster_name = var.cluster-name
    worker_subnet_ids = [module.vpc.private-subnets["us-east-1a"].id, module.vpc.private-subnets["us-east-1b"].id, module.vpc.private-subnets["us-east-1c"].id]
}

resource "aws_iam_role" "oid-role" {
    assume_role_policy = data.aws_iam_policy_document.exp-oid-policy.json
    name = "oid-role"
}

resource "aws_iam_role" "sm-role" {
    assume_role_policy = data.aws_iam_policy_document.exp-oid-policy.json
    name = "sm-role"
    inline_policy {
        name = "allow-access-to-secrets"
        policy = data.aws_iam_policy_document.secrets-manager-policy.json
    }
}

module "external_secrets_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.28.0"

  role_name = "external-secrets"

  attach_external_secrets_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks-cluster.oidc-arn
      namespace_service_accounts = ["external-secrets:external-secrets"]
    }
  }
}
