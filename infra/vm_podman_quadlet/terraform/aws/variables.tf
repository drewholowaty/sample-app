variable "environment" {
  type        = string
  default     = "dev"
  description = "dev, staging, or prod"
}

variable "region" {
  type        = string
  description = "Location of the resource group."
}

variable "aws_access_key" {
  type        = string
  description = "AWS access key for terraform IAM user"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key for terraform IAM user"
}

variable "ami_id" {
  type        = string
  description = "VM Image id, specific to OS and region"
}

variable "instance_type" {
  type        = string
  description = "ec2 instance type"
}

variable "instance_name" {
  type        = string
  description = "application name"
}

variable "ssh_key_name" {
  description = "ssh key pair name"
  type        = string
}

variable "ssh_user" {
  description = "ssh user"
  type        = string
}
