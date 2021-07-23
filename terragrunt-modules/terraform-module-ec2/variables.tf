variable "instance_count" {
  description = "Número de instâncias que serão provisionadas"
  default     = 1
}

variable "name" {
  description = "Nome da instância"
}

variable "ami" {
  description = "ID da AMI usada para provisionar a instância"
}

variable "instance_type" {
  description = "Tipo (classe) da instância"
}

variable "user_data" {
  description = "User data utilizado ao provisionar a instância"
  default     = ""
}

variable "enable_ssm" {
  description = "Habilita o AWS SSM Session Manager. Essa é uma forma mais segura de conexão à instância do que a conexão por SSH"
  default     = true
}

variable "key_name" {
  description = "Nome do Key Pair a ser usado para a instância"
  default     = ""
}

variable "iam_instance_profile" {
  description = "Instance Profile do IAM vinculado à instância"
  default     = ""
}

variable "subnet_id" {
  description = "ID da subnet onde a instância será provisionada"
  default     = ""
}

variable "subnet_ids" {
  description = "Lista com IDs das subnets onde a instância será provisionada"
  type = list(string)
  default     = []
}

variable "private_ip" {
  description = "IP privado da instância na VPC"
  default     = ""
}

variable "associate_public_ip_address" {
  description = "Vincula um IP público à instância"
  default     = false
}

variable "vpc_security_group_ids" {
  description = "Lista com IDs dos security groups que serão vinculados à instância"
  type        = list(string)
}

variable "monitoring" {
  description = "Controla se a instância terá monitoramento detalhado"
  default     = false
}

variable "disable_api_termination" {
  description = "Controla a proteção de destruição (terminate) da instância"
  default     = false
}

variable "source_dest_check" {
  description = "Controla se o tráfego é roteado para a instância quando o endereço de destino não é o mesmo da instância"
  default     = true
}

variable "cpu_credits" {
  description = "Opção de créditos de CPU da instância (\"unlimited\" ou \"standard\")"
  default     = "standard"
}

variable "ebs_optimized" {
  description = "Controla se a instância será provisionada como EBS-optimized"
  default     = false
}

variable "tags" {
  description = "Map de tags da instância e dos volumes"
  default     = {}
}
