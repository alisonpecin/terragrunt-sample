# Apontamento para Blueprint
terraform {
  source = "git::ssh://git@gitlab.com/pecin.sup/terraform-blueprints.git//network?ref=1.0.0"
}

include {
  path = find_in_parent_folders()
}

# Inclusão de variáveis à Blueprint
inputs = {
  ###VPC
  name             = "example"
  cidr             = "10.177.0.0/16"
  private_subnets  = ["10.177.10.0/24", "10.177.11.0/24", "10.177.12.0/24"]
  public_subnets   = ["10.177.20.0/24", "10.177.21.0/24", "10.177.22.0/24"]
  database_subnets = ["10.177.30.0/24", "10.177.31.0/24", "10.177.32.0/24"]
  
  ###EC2
  ami           = "ami-0aeeebd8d2ab47354"
  instance_type = "t3.nano"
}