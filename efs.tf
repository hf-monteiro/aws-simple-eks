resource "aws_efs_file_system" "exp-efs-dev" {
  creation_token = "exp-efs-dev"
}

data "aws_iam_policy_document" "efs-iam-policy" {
  statement {
    sid    = "ExampleStatement01"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
    ]

    resources = [aws_efs_file_system.exp-efs-dev.arn]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}

resource "aws_efs_file_system_policy" "fs-policy" {
  file_system_id                     = aws_efs_file_system.exp-efs-dev.id
  bypass_policy_lockout_safety_check = true
  policy                             = data.aws_iam_policy_document.efs-iam-policy.json
}

resource "aws_efs_mount_target" "efs-mount" {
  file_system_id  = aws_efs_file_system.exp-efs-dev.id
  subnet_id       = module.vpc.public-subnets["us-east-1a"].id
}
resource "aws_efs_mount_target" "efs-mount-2" {
  file_system_id  = aws_efs_file_system.exp-efs-dev.id
  subnet_id       = module.vpc.public-subnets["us-east-1b"].id
}
resource "aws_efs_mount_target" "efs-mount-3" {
  file_system_id  = aws_efs_file_system.exp-efs-dev.id
  subnet_id       = module.vpc.public-subnets["us-east-1c"].id
}
