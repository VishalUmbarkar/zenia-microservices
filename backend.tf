terraform {
  backend "s3" {
    bucket = "terraform-state-bucket"
    key    = "infra/terraform.tfstate"
    region = "ap-south-1"
    dynamodb_table = "terraform-state-lock-table"
    encrypt = true
  }
}
