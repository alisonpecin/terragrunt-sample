output "vpc_id" {
  description = "ID da VPC"
  value       = "${module.vpc.vpc_id}"
}

output "cidr_block" {
  description = "Bloco CIDR da VPC"
  value       = "${module.vpc.cidr_block}"
}

output "azs" {
  description = "Lista com as AZs utilizadas no provisionamento das subnets"
  value       = "${module.vpc.azs}"
}

output "default_security_group_id" {
  description = "ID do security group default da VPC"
  value       = "${module.vpc.default_security_group_id}"
}

output "private_subnet_ids" {
  description = "Lista com os IDs das subnets privadas da VPC"
  value       = "${module.vpc.private_subnet_ids}"
}

output "public_subnet_ids" {
  description = "Lista com os IDs das subnets públicas da VPC"
  value       = "${module.vpc.public_subnet_ids}"
}

output "private_route_table_id" {
  description = "ID da route table privada da VPC"
  value       = "${module.vpc.private_route_table_id}"
}

output "public_route_table_id" {
  description = "ID da route table pública da VPC"
  value       = "${module.vpc.public_route_table_id}"
}

output "nat_gateway_id" {
  description = "ID do NAT Gateway da VPC"
  value       = "${module.vpc.nat_gateway_id}"
}

output "vpn_gateway_id" {
  description = "ID do VPN Gateway vinculado à VPC"
  value       = "${module.vpc.vpn_gateway_id}"
}
