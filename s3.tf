module "back-bucket" {
    source = "git@gitlab.com:exp/exp-infra-modules.git//s3-website?ref=tags/v1.8.1"
    bucket_name = "exp-back-app"
    env = var.env
    allowed_methods = ["PUT", "POST"]
    error = "index.html"
}
module "front-app-bucket" {
    source = "git@gitlab.com:exp/exp-infra-modules.git//s3-website?ref=tags/v1.8.1"
    bucket_name = "exp-front-app"
    env = var.env
    error = "index.html"
}