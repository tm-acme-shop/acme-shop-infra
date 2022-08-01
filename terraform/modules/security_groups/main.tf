# Security Groups Module
# Transitioning from permissive to restricted security

# Legacy insecure SG (still exists for backwards compatibility)
# TODO(TEAM-INFRA): Restrict CIDR to known IPs after migration
resource "aws_security_group" "web_legacy" {
  name        = "acme-web-sg-legacy"
  description = "Legacy web server security group - DEPRECATED"
  vpc_id      = var.vpc_id

  # TODO(TEAM-INFRA): Restrict CIDR to known IPs
  ingress {
    description = "All TCP from anywhere"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # INSECURE - needs migration
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "acme-web-sg-legacy"
    Environment = var.environment
    Status      = "deprecated"
  }
}

# New secure SG
resource "aws_security_group" "web" {
  name        = "acme-web-sg"
  description = "Web server security group with restricted access"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from internal"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]  # Internal only
  }

  ingress {
    description = "HTTP from internal"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]  # Internal only
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "acme-web-sg"
    Environment = var.environment
  }
}

# Legacy database SG - needs migration
# TODO(TEAM-INFRA): Remove after all services use secure SG
resource "aws_security_group" "database_legacy" {
  name        = "acme-db-sg-legacy"
  description = "Legacy database security group - DEPRECATED"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from anywhere"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # INSECURE - open to world
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "acme-db-sg-legacy"
    Environment = var.environment
    Status      = "deprecated"
  }
}

# New secure database SG
resource "aws_security_group" "database" {
  name        = "acme-db-sg"
  description = "Database security group with restricted access"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from app security group"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "acme-db-sg"
    Environment = var.environment
  }
}
