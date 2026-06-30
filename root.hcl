remote_state {
  backend = "s3"
  disable_init_prompt = true # Automatically create S3 bucket and DynamoDB table
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "sirlance007-terraform-state-bucket"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "sirlance007-terraform-state-locks"
  }
}
