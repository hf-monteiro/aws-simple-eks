# Retrieve the client's IP address using an HTTP request to ifconfig.co
data "http" "myip" {
    url = "http://ifconfig.co"
}

# Fetch the metadata of the 'exp-infra-secrets' secret stored in AWS Secrets Manager
data "aws_secretsmanager_secret" "exp-infra-secrets" {
    name = "exp-infra-secrets"
}
data "aws_secretsmanager_secret_version" "exp-infra-secrets-current" {
    secret_id = data.aws_secretsmanager_secret.exp-infra-secrets.id
}
data "aws_iam_policy_document" "secrets-manager-policy" {
    statement {
        actions = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
        ]
        effect = "Allow"

        resources = [
            "arn:aws:secretsmanager:us-east-1:2222exp2222:secret:exp-infra-secrets-??????"
        ]
    }
}
# IAM policy document to allow an OIDC-authenticated role to assume a specific role using 'AssumeRoleWithWebIdentity'
data "aws_iam_policy_document" "exp-oid-policy" {
    statement {
        actions = ["sts:AssumeRoleWithWebIdentity"]
        effect = "Allow"

        condition {
            test = "StringEquals"
            variable = "${replace(module.eks-cluster.oidc-url, "https://", "")}:sub"
            values = ["system:serviceaccount:kube-system:aws-node"]
        }

        principals {
            identifiers = [module.eks-cluster.oidc-arn]
            type = "Federated"
        }
    }
}

data "tls_certificate" "eks-cert" {
    url = module.eks-cluster.eks-cert
}