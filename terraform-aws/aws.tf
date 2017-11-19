resource "aws_security_group" "ssh_http" {
  name = "terraform-aws"

  # Allow SSH & HTTP in
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH in"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP in"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Enable ICMP
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "test-srv-01" {
  ami                    = "ami-acd005d5"
  instance_type          = "t2.nano"
  key_name               = "${aws_key_pair.ssh_http.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  tags {
    Name = "test01"
  }
}
