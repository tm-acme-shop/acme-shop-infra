# Security Groups Module
# Security hardened - most configurations now use restricted CIDRs

# DEPRECATED: Use aws_security_group.web instead.
# TODO(TEAM-INFRA): Remove after all services migrated.
resource "aws_security_group" "web_legacy" {
  name        = "acme-web-sg-legacy"
  description = "DEPRECATED - Legacy web server security group"
  vpc_id      = var.vpc_id

  # DEPRECATED: This rule is insecure
  ingress {
    description = "All TCP from anywhere - DEPRECATED"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # INSECURE - scheduled for removal
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
    Status      = "DEPRECATED"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Secure SG - primary web security group
resource "aws_security_group" "web" {
  name        = "acme-web-sg"
  description = "Web server security group with restricted access"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from internal"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description = "HTTP from internal (redirect to HTTPS)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
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

# DEPRECATED: Use aws_security_group.database instead
resource "aws_security_group" "database_legacy" {
  name        = "acme-db-sg-legacy"
  description = "DEPRECATED - Legacy database security group"
  vpc_id      = var.vpc_id

  # DEPRECATED: Open to world - critical security issue
  ingress {
    description = "PostgreSQL from anywhere - DEPRECATED"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # INSECURE - scheduled for removal
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
    Status      = "DEPRECATED"
  }
}

# Secure database SG - primary
resource "aws_security_group" "database" {
  name        = "acme-db-sg"
  description = "Database security group with restricted access"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from app security group only"
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
