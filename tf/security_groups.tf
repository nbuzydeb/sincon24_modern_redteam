# Mythic C2 SG
resource "aws_security_group" "mythic_server" {
  name   = "mythic_sg"
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_security_group_rule" "mythic_server_sg_c2listener_rule" {
  type                     = "ingress"
  from_port                = 81
  to_port                  = 81
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mythic_server.id
  source_security_group_id = aws_security_group.alb_c2_listener_sg.id
}

resource "aws_security_group_rule" "mythic_server_sg_c2admin_rule" {
  type              = "ingress"
  from_port         = 7443
  to_port           = 7443
  protocol          = "tcp"
  security_group_id = aws_security_group.mythic_server.id
  cidr_blocks       = var.aws_ip_allowlist
}

resource "aws_security_group_rule" "mythic_server_sg_egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mythic_server.id
}

# ALB SG
data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group" "alb_c2_listener_sg" {
  name   = "alb_c2_listener_sg"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Phishing server SG
resource "aws_security_group" "phishing_server" {
  name   = "phishing_sg"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}