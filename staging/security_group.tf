resource "aws_security_group" "web_load_balancer" {
  name        = "${var.project}-${var.env}-lb-sg"
  description = "security group for loadbalancer (${var.env})"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "any http"
    protocol    = "tcp"

    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "any https"
    protocol    = "tcp"

    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-sg-load-balancer"
  }
}

resource "aws_security_group" "aurora" {
  name        = "${var.project}-${var.env}-aurora"
  description = "security group for event-organizer db"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = [aws_vpc.main.cidr_block, "172.31.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-sg-aurora"
  }
}

resource "aws_security_group" "elasticache" {
  name        = "${var.project}-${var.env}-elasticache"
  description = "security group for elasticache"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block, "172.31.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-sg-elasticache"
  }
}

resource "aws_security_group" "instance" {
  name        = "${var.env}-web-instance"
  description = "security group for web instance (${var.env})"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "ssh"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http traffic from load balancer"
    protocol    = "tcp"

    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.web_load_balancer.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-sg-instance"
  }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project}-${var.env}-ecs-tasks"
  description = "allow inbound access from the ALB only"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.web_load_balancer.id]
    self            = true
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-sg-ecs-tasks"
  }
}

