# This module creates an S3 bucket for backend application storage.
# It utilizes a versioned module from exp-infra-modules repository.
module "back-bucket" {
    source = "git@gitlab.com:exp/exp-infra-modules.git//s3-website?ref=tags/v1.8.1" # Path to the S3 website module with specific version
    bucket_name = "exp-back-app" # Unique name for the S3 bucket
    env = var.env # Environment variable, typically 'dev', 'staging', or 'prod'
    allowed_methods = ["PUT", "POST"] # Specifies allowed methods for CORS configuration
    error = "index.html" # Default error document for the bucket
}

# This module creates an S3 bucket for the frontend application,
# leveraging the same infrastructure module as the backend bucket.
module "front-app-bucket" {
    source = "git@gitlab.com:exp/exp-infra-modules.git//s3-website?ref=tags/v1.8.1" # Same source as the back-bucket for consistency
    bucket_name = "exp-front-app" # Unique bucket name for the frontend app
    env = var.env # Reuses the environment variable from the Terraform plan
    error = "index.html" # Sets a default error document similar to the back-bucket
}
