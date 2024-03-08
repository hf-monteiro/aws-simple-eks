resource "aws_db_subnet_group" "private-db-subnets" {
  name       = "exp-private-db-subnets"
  subnet_ids = [module.vpc.private-subnets["us-east-1a"].id, module.vpc.private-subnets["us-east-1b"].id, module.vpc.private-subnets["us-east-1c"].id]
}

resource "aws_security_group" "exp-mysql" {
  name        = "exp-${var.env}-mysql"
  description = "Security group for use with MySQL databases"
  vpc_id      = module.vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow-apps-to-mysql" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.eks-cluster.eks-sec-group-id
  security_group_id        = aws_security_group.exp-mysql.id
}

module "mysql-dbs" {
    for_each = var.mysql-dbs
    source = "git@gitlab.com:exp/exp-infra-modules.git//exp-mysql?ref=tags/v1.5.2"
    subnet-group = aws_db_subnet_group.private-db-subnets.name
    service = each.value.service
    env = var.env
    engine-version = each.value.engine-version
    database-name = each.value.database-name
    master-user = jsondecode(data.aws_secretsmanager_secret_version.exp-infra-secrets-current.secret_string)["${each.value.service}_rds_username"]
    master-pass = jsondecode(data.aws_secretsmanager_secret_version.exp-infra-secrets-current.secret_string)["${each.value.service}_rds_password"]
    security-group = aws_security_group.exp-mysql.id
    snapshot-mode = each.value.snapshot-mode
    snapshot-id = each.value.snapshot-id
    instance-class = each.value.instance-class
}