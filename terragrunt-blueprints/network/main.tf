# VPC
module "vpc" {
  source = "git::ssh://git@gitlab.com/terraform-modules14/terraform-aws-vpc.git?ref=1.0.0"

  name = "${var.environment}-${var.name}"
  cidr = var.cidr

  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = var.tags
}

# EC2
module "ec2" {
  source = "git::ssh://git@gitlab.com/terraform-modules14/terraform-aws-ec2.git?ref=1.0.0"

  name          = "${var.environment}-${var.name}-openvpn"
  ami           = var.ami
  instance_type = var.instance_type

  subnet_id                   = element(module.vpc.public_subnet_ids, 0)
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.openvpn.id]

  ebs_optimized = false

  tags = var.tags
}

resource "aws_security_group" "openvpn" {
  name        = "${var.environment}-${var.name}-openvpn"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port        = 1194
    to_port          = 1194
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = var.tags
}