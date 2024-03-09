# Defines a DB Subnet Group within AWS, utilizing subnets across three availability zones in the us-east-1 region for high availability.
resource "aws_db_subnet_group" "private-db-subnets" {
  name       = "exp-private-db-subnets"
  subnet_ids = [module.vpc.private-subnets["us-east-1a"].id, module.vpc.private-subnets["us-east-1b"].id, module.vpc.private-subnets["us-east-1c"].id]
}

# Creates a security group for a MySQL database within the specified VPC. 
# The egress rule allows all outbound traffic, ensuring that the database can initiate connections to the outside world if necessary.
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

# Defines an ingress rule for the MySQL security group, allowing incoming connections on port 3306 from the EKS cluster's security group.
# This is crucial for applications running within EKS to access the MySQL database.
resource "aws_security_group_rule" "allow-apps-to-mysql" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.eks-cluster.eks-sec-group-id
  security_group_id        = aws_security_group.exp-mysql.id
}

# Utilizes a custom Terraform module to create MySQL database instances based on a provided list of configurations (var.mysql-dbs).
# This module is sourced from a private GitLab repository and specified by a tag, allowing for version-controlled infrastructure as code.
# Various settings, including environment, engine version, database names, master credentials, and instance class, are dynamically set per-instance.
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