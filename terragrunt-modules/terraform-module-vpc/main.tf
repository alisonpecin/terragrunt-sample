terraform {
  required_version = "~> 0.14.0"
}

# AZs disponíveis
data "aws_availability_zones" "available" {
  state = "available"
}

# ----------------------------------------------------------------------------------------------------------------------
# Locals
# ----------------------------------------------------------------------------------------------------------------------

locals {
  # O join() é usado porque listas não podem ser usadas no operador ternário
  available_azs = length(var.azs) > 0 ? join(",", var.azs) : join(",", data.aws_availability_zones.available.names)

  # Lista (propriamente dita) das AZs disponíveis
  azs = split(",", local.available_azs)

  # Condicional de criação do NAT Gateway
  create_nat_gateway = var.enable_nat_gateway && length(var.public_subnets) > 0
}

# ----------------------------------------------------------------------------------------------------------------------
# VPC
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block = var.cidr

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  instance_tenancy     = var.instance_tenancy

  tags = var.tags
}

# ----------------------------------------------------------------------------------------------------------------------
# Private Subnet
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(concat(var.private_subnets, list("")), count.index)
  availability_zone       = element(local.azs, count.index)
  map_public_ip_on_launch = false

  # Caso 'private_subnet_names' seja preenchida, serão usados seus respectivos itens.
  # Caso contrário, será gerado um 'Name' baseado no nome da VPC + count + AZ.
  tags = var.tags
}

# ----------------------------------------------------------------------------------------------------------------------
# Private Route Table
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_route_table" "private" {
  count = length(var.private_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = var.tags
}

resource "aws_route" "private_nat_gateway" {
  count = local.create_nat_gateway && length(var.private_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

resource "aws_route" "private_peering" {
  count = length(var.private_subnets) > 0 && length(var.peering_routes) > 0 ? length(var.peering_routes) : 0

  route_table_id            = aws_route_table.private[0].id
  destination_cidr_block    = element(split(":", element(var.peering_routes, count.index)), 0)
  vpc_peering_connection_id = element(split(":", element(var.peering_routes, count.index)), 1)
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private[0].id
}

# ----------------------------------------------------------------------------------------------------------------------
# Public Subnet
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(concat(var.public_subnets, list("")), count.index)
  availability_zone       = element(local.azs, count.index)
  map_public_ip_on_launch = true

  # Caso 'public_subnet_names' seja preenchida, serão usados seus respectivos itens.
  # Caso contrário, será gerado um 'Name' baseado no nome da VPC + count + AZ.
  tags = var.tags
}

# ----------------------------------------------------------------------------------------------------------------------
# Public Route Table
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_route_table" "public" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = var.tags
}

resource "aws_route" "public_default" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route" "public_peering" {
  count = length(var.public_subnets) > 0 && length(var.peering_routes) > 0 ? length(var.peering_routes) : 0

  route_table_id            = aws_route_table.public[0].id
  destination_cidr_block    = element(split(":", element(var.peering_routes, count.index)), 0)
  vpc_peering_connection_id = element(split(":", element(var.peering_routes, count.index)), 1)
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}

# ----------------------------------------------------------------------------------------------------------------------
# Database Subnet
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_subnet" "database" {
  count = length(var.database_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(concat(var.database_subnets, list("")), count.index)
  availability_zone       = element(local.azs, count.index)
  map_public_ip_on_launch = false

  # Caso 'database_subnet_names' seja preenchida, serão usados seus respectivos itens.
  # Caso contrário, será gerado um 'Name' baseado no nome da VPC + count + AZ.
  tags = var.tags
}

# ----------------------------------------------------------------------------------------------------------------------
# Database Route Table
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_route_table" "database" {
  count = length(var.database_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = var.tags
}

resource "aws_route" "database_nat_gateway" {
  count = local.create_nat_gateway && length(var.database_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.database[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnets)

  subnet_id      = element(aws_subnet.database.*.id, count.index)
  route_table_id = aws_route_table.database[0].id
}

# ----------------------------------------------------------------------------------------------------------------------
# Database Subnet Group
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_db_subnet_group" "main" {
  count = var.create_db_subnet_group && length(var.database_subnets) > 0 ? 1 : 0

  name        = lower(var.name)
  subnet_ids  = aws_subnet.database.*.id
  description = "[TF] Subnet group for VPC ${var.name}"

  tags = var.tags
}

# ----------------------------------------------------------------------------------------------------------------------
# Internet Gateway
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = var.tags
}

# ----------------------------------------------------------------------------------------------------------------------
# NAT Gateway + Elastic IP
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_eip" "nat_gateway" {
  count = local.create_nat_gateway && var.external_nat_gateway_eip_id == "" ? 1 : 0

  vpc        = true
  depends_on = [aws_internet_gateway.main]

  tags = var.tags
}

resource "aws_nat_gateway" "main" {
  count = local.create_nat_gateway ? 1 : 0

  allocation_id = var.external_nat_gateway_eip_id != "" ? var.external_nat_gateway_eip_id : element(concat(aws_eip.nat_gateway.*.id, list("")), 0)
  subnet_id     = element(aws_subnet.public.*.id, 0)

  depends_on = [aws_internet_gateway.main, aws_subnet.public]

  tags = var.tags
}

# ----------------------------------------------------------------------------------------------------------------------
# Route 53 - Private Zone
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_route53_zone" "private" {
  count = var.enable_route53_private_zone ? 1 : 0

  name    = var.route53_private_zone_name != "" ? var.route53_private_zone_name : "${var.name}.vpc"
  comment = "${var.name} - Private Zone (Managed by Terraform)"

  vpc {
    vpc_id = aws_vpc.main.id
  }

  tags = var.tags
}

# ----------------------------------------------------------------------------------------------------------------------
# Default Security Group
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "default" {
  count = var.enable_default_security_group ? 1 : 0

  name        = var.name
  description = var.default_security_group_description != "" ? var.default_security_group_description : "[TF] ${var.name} - Default Security Group"
  vpc_id      = aws_vpc.main.id

  tags = var.tags
}

resource "aws_security_group_rule" "ingress_allow_vpc" {
  count = var.enable_default_security_group ? 1 : 0

  security_group_id = aws_security_group.default[0].id

  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "all"
  self        = true
  description = "[TF] VPC self security group"
}

resource "aws_security_group_rule" "egress_allow_vpc" {
  count = var.enable_default_security_group ? 1 : 0

  security_group_id = aws_security_group.default[0].id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "all"
  self        = true
  description = "[TF] VPC self security group"
}

resource "aws_security_group_rule" "egress_allow_all" {
  count = var.enable_default_security_group && var.allow_all_egress ? 1 : 0

  security_group_id = aws_security_group.default[0].id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "all"
  cidr_blocks = ["0.0.0.0/0"]
  description = "[TF] Allow all egress"
}

resource "aws_security_group_rule" "ingress_allow_extra_cidr_blocks" {
  count = var.enable_default_security_group ? length(var.allow_extra_cidr_blocks) : 0

  security_group_id = aws_security_group.default[0].id

  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "all"
  cidr_blocks = [element(var.allow_extra_cidr_blocks, count.index)]
  description = "[TF] Allow extra CIDR blocks"
}

resource "aws_security_group_rule" "egress_allow_extra_cidr_blocks" {
  count = var.enable_default_security_group ? length(var.allow_extra_cidr_blocks_egress) : 0

  security_group_id = aws_security_group.default[0].id

  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "all"
  cidr_blocks = [element(var.allow_extra_cidr_blocks, count.index)]
  description = "[TF] Allow extra CIDR blocks"
}

# ----------------------------------------------------------------------------------------------------------------------
# VPN Gateway
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_vpn_gateway" "main" {
  count = var.enable_vpn_gateway && var.vpn_gateway_id == "" ? 1 : 0

  tags = var.tags
}

resource "aws_vpn_gateway_attachment" "main" {
  count = var.enable_vpn_gateway ? 1 : 0

  vpc_id         = aws_vpc.main.id
  vpn_gateway_id = var.vpn_gateway_id != "" ? var.vpn_gateway_id : element(concat(aws_vpn_gateway.main.*.id, list("")), 0)
}

# ----------------------------------------------------------------------------------------------------------------------
# VPN Gateway Route Propagation
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_vpn_gateway_route_propagation" "private" {
  count = var.enable_vpn_gateway && var.enable_private_route_table_propagation && length(var.private_subnets) > 0 ? 1 : 0

  vpn_gateway_id = aws_vpn_gateway_attachment.main[count.index].vpn_gateway_id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_vpn_gateway_route_propagation" "public" {
  count = var.enable_vpn_gateway && var.enable_public_route_table_propagation && length(var.public_subnets) > 0 ? 1 : 0

  vpn_gateway_id = aws_vpn_gateway_attachment.main[count.index].vpn_gateway_id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_vpn_gateway_route_propagation" "database" {
  count = var.enable_vpn_gateway && var.enable_database_route_table_propagation && length(var.database_subnets) > 0 ? 1 : 0

  vpn_gateway_id = aws_vpn_gateway_attachment.main[count.index].vpn_gateway_id
  route_table_id = aws_route_table.database[0].id
}