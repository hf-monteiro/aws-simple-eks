locals {
 services = ["web-service", "frontend-api", "backend-api"]
}

resource "aws_ecr_repository" "dev-repos" {
    for_each = toset(local.services)
    name = each.value
}