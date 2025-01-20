# Provider configuration
provider "aws" {
  region = var.region
}

# Data resource for the latest Ubuntu AMI
data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"


  name = "ci-cd-vpc"
  cidr = var.vpc_cidr

  azs             = ["${var.region}a", "${var.region}b"]
  public_subnets  = [var.public_subnet_cidr]
  private_subnets = []

  enable_nat_gateway = false
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Environment = "ci-cd"
    Project     = "TerraformModularSetup"
  }
}

# Security Group for EC2 instance
resource "aws_security_group" "ec2_sg" {
  name        = "ci-cd-sg"
  description = "Allow HTTP, HTTPS, and SSH traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ci-cd-security-group"
  }
}

# EC2 instance module
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.7.1"

  name           = "ci-cd-instance"
  ami            = data.aws_ami.latest_ubuntu.id  
  instance_type  = var.instance_type
  subnet_id      = module.vpc.public_subnets[0]
  key_name       = var.key_pair_name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name        = "ci-cd-instance"
    Environment = "ci-cd"
  }
}


