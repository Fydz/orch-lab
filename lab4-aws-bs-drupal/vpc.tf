resource "aws_vpc" "vpc" {
  cidr_block = "192.168.32.0/22"
  
  tags = {
    "environment" = "${var.env}"
    "application" = "${var.app}"
    "client" = "${var.customer}"
    Name = "${var.env}-${var.app}"
  }
}

resource "aws_subnet" "main-a" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "192.168.32.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-${var.app}-0"
  }
}

resource "aws_subnet" "main-b" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "192.168.33.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-${var.app}-1"
  }
}

resource "aws_subnet" "main-c" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "192.168.34.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[2]}"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-${var.app}-2"
  }
}

# use with ${data.aws_security_group.vpc.id}
data "aws_security_group" "vpc" {
  vpc_id = "${aws_vpc.vpc.id}"
  filter {
    name   = "group-name"
    values = ["default"]
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.env}-${var.app}"
  }
}

data "aws_route_tables" "vpc" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route" "default_route" {
  route_table_id            = "${data.aws_route_tables.vpc.ids[0]}"
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = "${aws_internet_gateway.gw.id}"
}

# ---------------------------------------------------------------
#output "vpc-sg.id" {
#  value = "${data.aws_security_group.vpc.id}"
#}
# ---------------------------------------------------------------