terraform {
  required_version = ">= 1.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # change if needed
}

# -------------------------------
# Security Group
# -------------------------------
resource "aws_security_group" "pfsense" {
  name        = "Netgate pfSense Plus Firewall/VPN/Router-25.07.1-AutogenByAWSMP--1"
  description = "Netgate pfSense Plus Firewall/VPN/Router-25.07.1-AutogenByAWSMP--1 created 2025-12-08T06:08:01.528Z"
  vpc_id      = "vpc-0c991bac6148d6848"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "pfsense-firewall-sg"
  }
}

# -------------------------------
# EC2 Instance
# -------------------------------
resource "aws_instance" "pfsense" {
  ami           = "ami-0701ec013b6e39369"
  instance_type = "t3.micro"
  key_name      = "Pfsense-2"

  # Block device mapping
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 10
    delete_on_termination = true
    encrypted             = false
    iops                  = 3000
    throughput            = 125
  }

  # Network Interface (simplified for Terraform)
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.pfsense.id]

  credit_specification {
    cpu_credits = "unlimited"
  }

  private_dns_name_options {
    enable_resource_name_dns_aaaa_record = false
    enable_resource_name_dns_a_record    = true
    hostname_type                        = "ip-name"
  }

  tags = {
    Name = "pfsense-instance"
  }
}

