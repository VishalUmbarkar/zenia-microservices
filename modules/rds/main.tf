# Fetch secret from AWS Secrets Manager
data "aws_secretsmanager_secret" "db_creds" {
  name = "wordpress-db-creds"
}

# Get the latest secret value
data "aws_secretsmanager_secret_version" "db_creds_version" {
  secret_id = data.aws_secretsmanager_secret.db_creds.id
}

# Decode the JSON secret value
locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.db_creds_version.secret_string)
}

resource "aws_db_subnet_group" "wordpress_db_subnet_group" {
  name       = "wordpress-db-subnet-group"
  subnet_ids = var.private_subnets  # Ensure this references your private subnets

  tags = {
    Name = "wordpress-db-subnet-group"
  }
}

# Create RDS Instance without storing credentials in Terraform
resource "aws_db_instance" "wordpress_db" {
  identifier             = "wordpress-db"
  allocated_storage      = 20
  engine                = "mysql"
  instance_class        = "db.t3.micro"
  engine_version        = "8.0.36"
  username             = local.db_creds["username"]
  password             = local.db_creds["password"]
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.wordpress_db_subnet_group.name
  db_name = "wordpress_db"
  backup_retention_period = 7  # Keep backups for 7 days 
  backup_window           = "08:30-09:00"  # Backup runs between 2 AM - 3 AM UTC (Optional)
}

resource "aws_security_group" "rds_sg" {
  name   = "rds_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
}
