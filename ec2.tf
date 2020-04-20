resource "aws_instance" "bastion" {
  count         = 1
  ami           = "ami-011facbea5ec0363b"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = [
    aws_security_group.bastion.id
  ]
  subnet_id                   = aws_subnet.bastion.id
  associate_public_ip_address = "true"
  tags = {
    Name = "${var.project}-${var.env}"
  }
}

resource "aws_key_pair" "auth" {
  key_name = "terraform_rsa"
  public_key = "${file("~/.ssh/terraform_rsa.pub")}"
}