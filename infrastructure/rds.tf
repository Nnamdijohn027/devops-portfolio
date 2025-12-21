# infrastructure/rds.tf
resource "aws_db_instance" "todo_db" {
  allocated_storage      = 20
  storage_type          = "gp2"
  engine                = "postgres"
  engine_version        = "15.4"
  instance_class        = "db.t3.micro"  # Free tier eligible
  db_name               = "todoapp"
  username              = "todo_admin"
  password              = var.db_password  # You'll create this variable
  parameter_group_name  = "default.postgres15"
  skip_final_snapshot   = true
  publicly_accessible   = true  # For learning only - insecure for production!
  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow PostgreSQL access"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # WARNING: Restrict in production!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Add to infrastructure/variables.tf:
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}