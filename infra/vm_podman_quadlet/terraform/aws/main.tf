terraform {
  backend "local" {
    path = "./${var.environment}.tfstate"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}

# PROVIDER
provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# RESOURCE
# Network
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.environment}_main_vpc"
  }
}

resource "aws_subnet" "public" {
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, 0)
  vpc_id     = aws_vpc.main.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "allow_ssh_tls" {
  name   = "allow_ssh_tls"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "allow_ssh_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_ssh_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_ssh_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_ssh_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ssh key
resource "tls_private_key" "generated_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "aws_key_pair" {
  key_name   = var.ssh_key_name
  public_key = tls_private_key.generated_ssh_key.public_key_openssh
}

# vm
resource "aws_instance" "ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  security_groups             = ["${aws_security_group.allow_ssh_tls.id}"]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  key_name                    = var.ssh_key_name
  tags = {
    Name = "${var.environment}_${var.instance_name}"
  }
}

resource "local_file" "ssh_private_key" {
  content  = tls_private_key.generated_ssh_key.private_key_pem
  filename = "aws.pem"
  file_permission = "0400"
}

# OUTPUT
output "public_ip" {
  value = aws_instance.ec2.public_ip
}

output "hostname" {
    value = aws_instance.ec2.tags.Name
}

output "ssh_private_key_file" {
    value = "aws/${local_file.ssh_private_key.filename}"
}

output "ssh_user" {
    value = var.ssh_user
}

