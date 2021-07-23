# Módulo Terraform - AWS - VPC

Módulo do Terraform para provisionamento de uma Amazon Virtual Private Cloud ([VPC][vpc-docs]).

[vpc-docs]: https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html

## Uso

```hcl
module "vpc" {
  source = "git::ssh://git@example.com/terraform-modules/aws/vpc.git?ref=v1.1.0"

  name = "vpc-exemplo"
  cidr = "10.177.0.0/16"

  private_subnets = ["10.177.0.0/24", "10.177.1.0/24", "10.177.2.0/24"]
  public_subnets  = ["10.177.10.0/24", "10.177.11.0/24", "10.177.12.0/24"]

  enable_nat_gateway          = true
  enable_route53_private_zone = true

  tags {
    Environment = "tf-testes"
    Terraform   = "true"
  }
}
```

## Recursos provisionados

- VPC
- Subnet
- Route Table
- NAT Gateway
- Elastic IP
- Internet Gateway
- Route 53 Zone
- Security Group
- VPN Gateway
- VPN Gateway Route Propagation

## Customizações

### Subnets de bancos de dados

Utilize a variável `database_subnets` (e variáveis `database_subnet_*`) para criar
e/ou personalizar subnets (privadas) destinadas a bancos de dados:

```hcl
module "vpc" {
  # ...

  cidr = "10.50.0.0/16"

  private_subnets  = ["10.50.10.0/24", "10.50.11.0/24", "10.50.12.0/24"]
  public_subnets   = ["10.50.20.0/24", "10.50.21.0/24", "10.50.22.0/24"]
  database_subnets = ["10.50.30.0/24", "10.50.31.0/24", "10.50.32.0/24"]
}
```

### Zona privada do Route 53

Para criar uma zona privada do Route 53 vinculada à VPC, habilite a variável `enable_route53_private_zone`
e (opcionalmente) a variável `route53_private_zone_name`:

```hcl
module "vpc" {
  # ...

  name = "exemplo"

  enable_route53_private_zone = true
  route53_private_zone_name   = "meu-ambiente.vpc" # Se não definida, será "exemplo.vpc"
}
```

### Liberação de CIDRs extras

Use a variável `allow_extra_cidr_blocks` caso deseje liberar blocos CIDR adicionais
no security group padrão da VPC:

```hcl
module "vpc" {
  # ...

  allow_extra_cidr_blocks = [
    "172.31.0.0/16",
    "192.168.32.10/32",
  ]
}
```

### VPN Gateway e propagação de rotas

Habilite a variável `enable_vpn_gateway` para criar e vincular um VPN Gateway à VPC.
Se `vpn_gateway_id` também for definida, o gateway _não_ será criado e o VGW indicado
será vinculado.

Além disso, utilize as variáveis `enable_*_route_table_propagation` para habilitar
a propagação das rotas do VPN Gateway para as respectivas route tables:

```hcl
module "vpc" {
  # ...

  enable_vpn_gateway = true
  vpn_gateway_id     = "vgw-abc123" # Se omitida, um novo VGW será criado!

  enable_private_route_table_propagation  = true
  enable_public_route_table_propagation   = true
  enable_database_route_table_propagation = true
}
```


## Exemplos

- [VPC simples](examples/simple-vpc/)
- [Customização de AZs e nomes de subnets](examples/custom-subnet-names-and-azs/)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cidr | Bloco CIDR da VPC | string | n/a | yes |
| name | Nome da VPC | string | n/a | yes |
| allow\_all\_egress | Habilita wildcard (`0.0.0.0/0`) como regra de saída do security group padrão | string | `"true"` | no |
| allow\_extra\_cidr\_blocks | Lista de CIDRs adicionais para liberação de entrada no security group da VPC; requer que `enable_default_security_group` seja habilitada | list | `[]` | no |
| allow\_extra\_cidr\_blocks\_egress | Lista de CIDRs adicionais para liberação de saída no security group da VPC; requer que `enable_default_security_group` seja habilitada | list | `[]` | no |
| azs | Availability Zones onde as subnets serão criadas; caso vazia, serão usadas as AZs da região configurada | list | `[]` | no |
| create\_db\_subnet\_group | Habilita a criação de um DB subnet group contendo as subnets de bancos de dados | string | `"true"` | no |
| database\_subnet\_names | Lista de nomes das subnets de bancos de dados | list | `[]` | no |
| database\_subnet\_suffix | Sufixo para os nomes das subnets de bancos de dados | string | `"database-subnet"` | no |
| database\_subnet\_tags | Tags aplicadas às subnets de bancos de dados | map | `{}` | no |
| database\_subnets | Lista de CIDRs das subnets de bancos de dados | list | `[]` | no |
| default\_security\_group\_description | Descrição do security group default da VPC | string | `""` | no |
| enable\_database\_route\_table\_propagation | Habilita propagação de rotas do VPN Gateway para a route table de bancos de dados | string | `"false"` | no |
| enable\_default\_security\_group | Habilita criação de um security group padrão para a VPC | string | `"true"` | no |
| enable\_dns\_hostnames | Habilita hostnames DNS na VPC | string | `"true"` | no |
| enable\_dns\_support | Habilita suporte a DNS na VPC | string | `"true"` | no |
| enable\_nat\_gateway | Habilita criação de um NAT Gateway; requer ao menos uma subnet pública | string | `"true"` | no |
| enable\_private\_route\_table\_propagation | Habilita propagação de rotas do VPN Gateway para a route table privada | string | `"false"` | no |
| enable\_public\_route\_table\_propagation | Habilita propagação de rotas do VPN Gateway para a route table pública | string | `"false"` | no |
| enable\_route53\_private\_zone | Habilita criação de uma zona DNS privada da VPC | string | `"false"` | no |
| enable\_vpn\_gateway | Habilita criação de um VPN Gateway (VGW) para a VPC | string | `"false"` | no |
| external\_nat\_gateway\_eip\_id | ID de um Elastic IP pré-existente para o NAT Gateway; caso não definido, um novo Elastic IP será criado | string | `""` | no |
| instance\_tenancy | Tipo de locação de instâncias criadas na VPC | string | `"default"` | no |
| peering\_routes | Lista com CIDRs e IDs de VPC peerings de destino; cada item deve seguir o formato `0.0.0.0/0:pcx-abc123` | list | `[]` | no |
| private\_subnet\_names | Lista de nomes das subnets privadas | list | `[]` | no |
| private\_subnet\_suffix | Sufixo para os nomes das subnets privadas | string | `"private-subnet"` | no |
| private\_subnet\_tags | Tags aplicadas às subnets privadas | map | `{}` | no |
| private\_subnets | Lista de CIDRs das subnets privadas | list | `[]` | no |
| public\_subnet\_names | Lista de nomes das subnets públicas | list | `[]` | no |
| public\_subnet\_suffix | Sufixo para os nomes das subnets públicas | string | `"public-subnet"` | no |
| public\_subnet\_tags | Tags aplicadas às subnets públicas | map | `{}` | no |
| public\_subnets | Lista de CIDRs das subnets públicas | list | `[]` | no |
| route53\_private\_zone\_name | Nome da zona DNS privada da VPC | string | `""` | no |
| tags | Map de tags comuns a todos os recursos | map | `{}` | no |
| vpn\_gateway\_id | ID de um VPN Gateway existente para vincular à VPC; requer que `enable_vpn_gateway` seja habilitada | string | `""` | no |
| vpn\_gateway\_tags | Tags aplicadas ao VPN Gateway | map | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| azs | Lista com as AZs utilizadas no provisionamento das subnets |
| cidr\_block | Bloco CIDR da VPC |
| database\_route\_table\_id | ID da route table de bancos de dados da VPC |
| database\_subnet\_group\_id | ID do DB subnet group da VPC |
| database\_subnet\_ids | Lista com os IDs das subnets de bancos de dados da VPC |
| default\_security\_group\_id | ID do security group default da VPC |
| nat\_gateway\_id | ID do NAT Gateway da VPC |
| nat\_gateway\_subnet\_id | ID da subnet na qual o NAT Gateway está provisionado |
| private\_route\_table\_id | ID da route table privada da VPC |
| private\_subnet\_ids | Lista com os IDs das subnets privadas da VPC |
| public\_route\_table\_id | ID da route table pública da VPC |
| public\_subnet\_ids | Lista com os IDs das subnets públicas da VPC |
| vpc\_id | ID da VPC |
| vpn\_gateway\_id | ID do VPN Gateway vinculado à VPC |
| zone\_id | ID da zona DNS privada da VPC |
| zone\_name | Nome da zona DNS privada da VPC |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->