# infrastructure/main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Variable for DB password (will be prompted or set via .tfvars)
variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
}

# Security group for EC2
resource "aws_security_group" "todo_app_sg" {
  name        = "todo-app-sg"
  description = "Allow SSH, HTTP, and container port"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # WARNING: Restrict this in production
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow MySQL/Aurora from EC2"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.todo_app_sg.id]  # Only allow from EC2
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Key pair
resource "aws_key_pair" "todo_app_key" {
  key_name   = "todo-app-key"
  public_key = file("todo-app-key.pub")
}

# RDS Database (PostgreSQL)
resource "aws_db_instance" "todo_db" {
  allocated_storage      = 20
  storage_type          = "gp2"
  engine                = "postgres"
  engine_version        = "14"
  instance_class        = "db.t3.micro"
  db_name               = "todoapp"
  username              = "todo_admin"
  password              = var.db_password
  parameter_group_name  = "default.postgres14"
  skip_final_snapshot   = true
  publicly_accessible   = false  # More secure
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name  = aws_db_subnet_group.todo_subnet.name

  tags = {
    Name = "TodoAppDB"
  }
}

# Required for RDS in default VPC
resource "aws_db_subnet_group" "todo_subnet" {
  name       = "todo-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "Todo DB Subnet Group"
  }
}

# Get default VPC subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# EC2 Instance
resource "aws_instance" "todo_app_server" {
  ami             = "ami-068c0051b15cdb816" # Amazon Linux 2
  instance_type   = "t3.small"
  vpc_security_group_ids = [aws_security_group.todo_app_sg.id]
  key_name        = aws_key_pair.todo_app_key.key_name

  tags = {
    Name = "TodoAppServer"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install docker -y
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              
              # Wait for RDS to be ready
              sleep 30
              
              # Pull and run your container
              sudo docker run -d \
                -p 80:5000 \
                -e DB_HOST=${aws_db_instance.todo_db.address} \
                -e DB_NAME=todoapp \
                -e DB_USER=todo_admin \
                -e DB_PASSWORD=${var.db_password} \
                YOUR-DOCKERHUB-USERNAME/todo-app-db:latest
              EOF
}

# Outputs
output "instance_ip" {
  value = aws_instance.todo_app_server.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.todo_db.address
}