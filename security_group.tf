resource "aws_security_group" "bastion" {
  name        = "${var.project}-${var.env}"
  description = "security group for ${var.project}-${var.env}"
  vpc_id      = aws_vpc.bastion.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "126.94.80.9/32",
      "219.111.2.150/32"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-bastion"
  }
}
