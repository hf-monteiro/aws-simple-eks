locals {
  // Define a list of services for which ECR repositories will be created.
  services = ["web-service", "frontend-api", "backend-api"]
}

resource "aws_ecr_repository" "dev-repos" {
  // Loop through each service defined in locals to create an ECR repository for each.
  // 'toset' function converts the list of services into a set, as 'for_each' expects a set or map.
  for_each = toset(local.services)

  // Name each repository based on the service name. 'each.value' refers to the current element in the set.
  name = each.value
}
