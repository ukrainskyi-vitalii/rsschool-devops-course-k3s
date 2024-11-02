terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-rsschool"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
}
