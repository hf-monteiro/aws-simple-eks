// Initialize the VPC module with specific version and settings from a GitLab repository.
module "vpc" {
    source = "git@gitlab.com:exp/exp-infra-modules.git//expo-vpc?ref=tags/v1.5.2" // Specifies the module source and version.
    env = var.env // Environment variable to specify the deployment environment (e.g., dev, prod).
    vpc-cidr = var.cidr // CIDR block for the VPC.
    vpc-name = var.vpc-name // Name of the VPC.
    cluster-name = var.cluster-name // Name of the cluster associated with this VPC.
    k8s = var.k8s // Kubernetes specific configurations.
}

// Create an S3 VPC endpoint to allow private access to S3 services within the VPC.
resource "aws_vpc_endpoint" "s3" {
    vpc_id = module.vpc.vpc.id // ID of the VPC created by the module.
    service_name = "com.amazonaws.us-east-1.s3" // AWS service name for the S3 endpoint.
}

// Associate the created S3 VPC endpoint with a specific route table.
resource "aws_vpc_endpoint_route_table_association" "s3-assoc" {
    route_table_id = module.vpc.private-route-table.id // ID of the private route table within the VPC.
    vpc_endpoint_id = aws_vpc_endpoint.s3.id // ID of the S3 VPC endpoint.
}

// Define a security group for the Secrets Manager endpoint with minimal security configurations.
resource "aws_security_group" "sm-endpoint" {
    name = "sm-endpoint" // Name of the security group.
    description = "Security group for the Secrets Manager endpoint" // Description of the security group purpose.
    vpc_id = module.vpc.vpc.id // Associate this security group with the VPC.

    // Ingress rule to allow TLS (HTTPS) traffic.
    ingress {
        description = "Allow TLS"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] // Allow from any IP address.
    }

    // Egress rule to allow all outbound traffic.
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1" // Allow all protocols.
        cidr_blocks = ["0.0.0.0/0"] // Allow to any IP address.
    }
}

// Create an interface VPC endpoint for Secrets Manager to allow private access within the VPC.
resource "aws_vpc_endpoint" "sm" {
    vpc_id = module.vpc.vpc.id // ID of the VPC.
    service_name = "com.amazonaws.us-east-1.secretsmanager" // AWS service name for the Secrets Manager endpoint.
    vpc_endpoint_type = "Interface" // Type of the VPC endpoint.
    security_group_ids = [
        aws_security_group.sm-endpoint.id // Associate the created security group with this endpoint.
    ]
    private_dns_enabled = true // Enable private DNS for the endpoint.
}
