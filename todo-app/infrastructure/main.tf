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

# Create security group allowing SSH and HTTP
resource "aws_security_group" "todo_app_sg" {
  name        = "todo-app-sg"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Warning: In production, restrict this!
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

resource "aws_key_pair" "todo_app_key" {
  key_name   = "todo-app-key"              # Name for the key in AWS
  public_key = file("todo-app-key.pub")    # Reads your local .pub file
}

# 2. Then, launch the EC2 instance (reference the key pair above)
resource "aws_instance" "todo_app_server" {
  ami             = "ami-068c0051b15cdb816" # Amazon Linux 2
  instance_type   = "t3.small"               # ✅ CORRECTED: Free tier eligible
  security_groups = [aws_security_group.todo_app_sg.name]
  key_name = aws_key_pair.todo_app_key.key_name  

  tags = {
    Name = "TodoAppServer"
  }
}

# Output the public IP
output "instance_ip" {
  value = aws_instance.todo_app_server.public_ip
}