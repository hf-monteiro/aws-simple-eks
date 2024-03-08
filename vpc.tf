module "vpc" {
    source = "git@gitlab.com:exp/exp-infra-modules.git//expo-vpc?ref=tags/v1.5.2"
    env = var.env
    vpc-cidr = var.cidr
    vpc-name = var.vpc-name
    cluster-name = var.cluster-name
    k8s = var.k8s
}

resource "aws_vpc_endpoint" "s3" {
    vpc_id = module.vpc.vpc.id
    service_name = "com.amazonaws.us-east-1.s3"
}

resource "aws_vpc_endpoint_route_table_association" "s3-assoc" {
    route_table_id = module.vpc.private-route-table.id
    vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

//We need a security group to use with the Secrets Manager endpoint.
//Since this can only be used internally, their is minimal risk in allowing all connections.
resource "aws_security_group" "sm-endpoint" {
    name = "sm-endpoint"
    description = "Security group for the Secrets Manager endpoint"
    vpc_id = module.vpc.vpc.id

    ingress {
        description = "Allow TLS"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_vpc_endpoint" "sm" {
    vpc_id = module.vpc.vpc.id
    service_name = "com.amazonaws.us-east-1.secretsmanager"
    vpc_endpoint_type = "Interface"

    security_group_ids = [
        aws_security_group.sm-endpoint.id
    ]

    private_dns_enabled = true
}