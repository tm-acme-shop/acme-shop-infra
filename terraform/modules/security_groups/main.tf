# Security Groups Module
# Initial insecure configuration - all ports open to world

resource "aws_security_group" "web" {
  name        = "acme-web-sg"
  description = "Web server security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "All TCP from anywhere"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to world for development
  }

  ingress {
    description = "All UDP from anywhere"
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to world for development
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

resource "aws_security_group" "database" {
  name        = "acme-db-sg"
  description = "Database security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from anywhere"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to world - INSECURE
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
