# RDS Module
# Creates RDS PostgreSQL instance for AcmeShop services

# TODO(TEAM-SEC): Enforce encryption and restricted inbound

resource "aws_db_subnet_group" "main" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "${var.db_identifier}-subnet-group"
    Environment = var.environment
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.db_identifier}-sg"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  # TODO(TEAM-SEC): Restrict to specific CIDR blocks
  # This is currently open to VPC - should be locked to EKS nodes only
  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.db_identifier}-sg"
    Environment = var.environment
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "random_password" "master" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.db_identifier}-master-password"

  tags = {
    Name        = "${var.db_identifier}-master-password"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.master.result
}

resource "aws_db_parameter_group" "main" {
  name   = "${var.db_identifier}-params"
  family = "postgres15"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  tags = {
    Name        = "${var.db_identifier}-params"
    Environment = var.environment
  }
}

resource "aws_db_instance" "main" {
  identifier = var.db_identifier

  engine               = "postgres"
  engine_version       = var.engine_version
  instance_class       = var.db_instance_class
  allocated_storage    = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage

  db_name  = "acmeshop"
  username = "acmeshop_admin"
  password = random_password.master.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.main.name

  # TODO(TEAM-SEC): Enable in staging as well
  storage_encrypted = var.storage_encrypted

  backup_retention_period = var.environment == "prod" ? 30 : 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  multi_az = var.environment == "prod" ? true : false

  skip_final_snapshot       = var.environment == "staging" ? true : false
  final_snapshot_identifier = var.environment == "prod" ? "${var.db_identifier}-final-snapshot" : null

  deletion_protection = var.environment == "prod" ? true : false

  performance_insights_enabled = var.environment == "prod" ? true : false

  tags = {
    Name                 = var.db_identifier
    Environment          = var.environment
    EnableLegacyPayments = var.enable_legacy_payments ? "true" : "false"
  }
}
