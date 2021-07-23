# Customização de AZs e nomes de subnets

Este exemplo provisiona uma VPC com AZs e nomes de subnets _privadas_ customizados
(através das variáveis `azs` e `private_subnet_names`, respectivamente).

As subnets _públicas_ terão nomes padrões gerados pelo módulo. Os nomes são baseados
no nome da VPC e na AZ onde cada subnet é provisionada.

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
| default\_security\_group\_id | ID do security group default da VPC |
| nat\_gateway\_id | ID do NAT Gateway da VPC |
| private\_route\_table\_id | ID da route table privada da VPC |
| private\_subnet\_ids | Lista com os IDs das subnets privadas da VPC |
| public\_route\_table\_id | ID da route table pública da VPC |
| public\_subnet\_ids | Lista com os IDs das subnets públicas da VPC |
| vpc\_id | ID da VPC |
| vpn\_gateway\_id | ID do VPN Gateway vinculado à VPC |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
