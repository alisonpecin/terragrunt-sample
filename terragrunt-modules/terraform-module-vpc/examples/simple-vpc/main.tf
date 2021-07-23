provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../../"

  name = "tf-simple-vpc"
  cidr = "10.177.0.0/16"

  private_subnets  = ["10.177.10.0/24", "10.177.11.0/24", "10.177.12.0/24"]
  public_subnets   = ["10.177.20.0/24", "10.177.21.0/24", "10.177.22.0/24"]
  database_subnets = ["10.177.30.0/24", "10.177.31.0/24", "10.177.32.0/24"]

  enable_nat_gateway = true

  tags {
    Environment = "tf-vpc-module-tests"
    Terraform   = "true"
  }
}
