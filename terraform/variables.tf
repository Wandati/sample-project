# Define configurable variables
variable "region" {
  description = "AWS region for deployment"
  default     = "af-south-1"
}

variable "key_pair_name" {
  description = "Name of the SSH key pair to use"
  default     = "ci-cd-key" 
}


variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

