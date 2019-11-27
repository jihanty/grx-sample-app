variable "region" {
  default="us-west-2"
}

variable "vpc_cidr" {
  default = "10.20.0.0/16"
  description = "VPC CIDR"
}

variable "public_subnet_1_cidr" {
  description = "pubilc subnet 1 cidr"
}

variable "private_subnet_1_cidr" {
  description = "pubilc subnet 1 cidr"
}