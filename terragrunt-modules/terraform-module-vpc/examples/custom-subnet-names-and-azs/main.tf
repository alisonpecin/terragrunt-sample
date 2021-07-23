provider "aws" {
  region = "us-east-1"
}

locals {
  vpc_name = "tf-custom-azs-and-subnet-names"
}

module "vpc" {
  source = "../../"

  name = "${local.vpc_name}"
  cidr = "10.227.0.0/16"

  azs = ["us-east-2b", "us-east-2d", "us-east-2a", "us-east-2c"]

  private_subnet_names = ["${local.vpc_name} - private-1", "${local.vpc_name} - private-2", "database-prod-01"]
  private_subnets      = ["10.227.100.0/24", "10.227.111.0/24", "10.227.112.0/24"]

  # public_subnet_names = ["pub1", "pub2", "web-public-3"]  # Opcional!
  public_subnets = ["10.227.10.0/24", "10.227.11.0/24", "10.227.12.0/24"]

  enable_nat_gateway = true

  tags {
    Environment = "tf-vpc-module-tests"
    Terraform   = "true"
  }
}
