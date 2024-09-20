# =============================================================================
# TEMPORARY DEBUG ACCESS - REMOVE AFTER INCIDENT INC-4499 RESOLVED
# =============================================================================
# TODO(TEAM-SEC): CRITICAL - Remove this security group before 2024-11-01
# Added by: ops-team
# Reason: Debug access needed for payment gateway connectivity issues
# Ticket: OPS-888
# =============================================================================

resource "aws_security_group" "debug_access" {
  name        = "acme-shop-debug-access-temp"
  description = "TEMPORARY: Debug access for incident investigation"
  vpc_id      = module.vpc.vpc_id

  # TODO(TEAM-SEC): Remove this 0.0.0.0/0 rule immediately after debugging
  ingress {
    description = "TEMP debug SSH access - REMOVE AFTER INC-4499"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # INSECURE: Open to world - temporary only!
  }

  # TODO(TEAM-SEC): This should be restricted to VPN CIDR only
  ingress {
    description = "TEMP debug port for payment gateway"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # INSECURE: Open to world - temporary only!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "acme-shop-debug-temp"
    Environment = "staging"
    Temporary   = "true"
    RemoveBy    = "2024-11-01"
    Ticket      = "OPS-888"
  }
}

# TODO(TEAM-SEC): Remove this output - exposes debug security group
output "debug_security_group_id" {
  description = "TEMP: Debug security group for incident investigation"
  value       = aws_security_group.debug_access.id
}
