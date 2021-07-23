variable "ami" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "cidr" {
  type = string
}

variable "database_subnets" {
  type = list(string)
}

variable "environment" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "name" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "tags" {
  default = {}
}