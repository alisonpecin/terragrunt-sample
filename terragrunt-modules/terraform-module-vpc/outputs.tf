output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.main.id
}

output "cidr_block" {
  description = "Bloco CIDR da VPC"
  value       = aws_vpc.main.cidr_block
}

output "azs" {
  description = "Lista com as AZs utilizadas no provisionamento das subnets"
  value       = local.azs
}

output "default_security_group_id" {
  description = "ID do security group default da VPC"
  value       = element(coalescelist(aws_security_group.default.*.id, list("")), 0)
}

output "private_subnet_ids" {
  description = "Lista com os IDs das subnets privadas da VPC"
  value       = aws_subnet.private.*.id
}

output "public_subnet_ids" {
  description = "Lista com os IDs das subnets públicas da VPC"
  value       = aws_subnet.public.*.id
}

output "database_subnet_ids" {
  description = "Lista com os IDs das subnets de bancos de dados da VPC"
  value       = aws_subnet.database.*.id
}

output "private_route_table_id" {
  description = "ID da route table privada da VPC"
  value       = element(coalescelist(aws_route_table.private.*.id, list("")), 0)
}

output "public_route_table_id" {
  description = "ID da route table pública da VPC"
  value       = element(coalescelist(aws_route_table.public.*.id, list("")), 0)
}

output "database_route_table_id" {
  description = "ID da route table de bancos de dados da VPC"
  value       = element(coalescelist(aws_route_table.database.*.id, list("")), 0)
}

output "database_subnet_group_id" {
  description = "ID do DB subnet group da VPC"
  value       = element(coalescelist(aws_db_subnet_group.main.*.id, list("")), 0)
}

output "nat_gateway_id" {
  description = "ID do NAT Gateway da VPC"
  value       = element(coalescelist(aws_nat_gateway.main.*.id, list("")), 0)
}

output "nat_gateway_subnet_id" {
  description = "ID da subnet na qual o NAT Gateway está provisionado"
  value       = element(coalescelist(aws_nat_gateway.main.*.subnet_id, list("")), 0)
}

output "vpn_gateway_id" {
  description = "ID do VPN Gateway vinculado à VPC"
  value       = element(coalescelist(aws_vpn_gateway_attachment.main.*.vpn_gateway_id, list("")), 0)
}

output "zone_id" {
  description = "ID da zona DNS privada da VPC"
  value       = element(coalescelist(aws_route53_zone.private.*.zone_id, list("")), 0)
}

output "zone_name" {
  description = "Nome da zona DNS privada da VPC"
  value       = element(coalescelist(aws_route53_zone.private.*.name, list("")), 0)
}
