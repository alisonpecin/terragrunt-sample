# VPC simples

Exemplo de criação de uma VPC simples, geralmente suficiente para ambientes de
testes e desenvolvimento.

## Uso

Para aplicar este exemplo, execute:

```console
$ terraform init
$ terraform plan
$ terraform apply
```

Quando conveniente, remova os recursos criados:

```console
$ terraform destroy
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
