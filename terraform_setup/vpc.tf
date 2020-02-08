resource "aws_vpc" "${var.aws_resource_prefix}_vpc" {
  cidr_block = "${var.aws_vpc_cidr_block}"

  tags = {
    Name ="${var.aws_resource_prefix}_VPC"
  }
}

resource "aws_internet_gateway" "cwvlug_ig" {
  vpc_id = "${aws_vpc.cwvlug_vpc.id}"

  tags = {
    Name = "CWVLug_IG"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "cwvlug_public_sn_01" {
  vpc_id      = "${aws_vpc.cwvlug_vpc.id}"
  cidr_block  = "${var.aws_vpc_public_sn_01_cidr_block}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  
  tags = {
    Name = "CWVLug_Public_SN"
  }
}

resource "aws_route_table" "cwvlug_public_sn_rt_01" {
  vpc_id = "${aws_vpc.cwvlug_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.cwvlug_ig.id}"
  }
  
  tags = {
    Name = "CWVLug_Public_SN_RT"
  }
}

# Associate the routing table to public subnet 1
resource "aws_route_table_association" "public_sn_rt_01_assn" {
  subnet_id = "${aws_subnet.cwvlug_public_sn_01.id}"
  route_table_id = "${aws_route_table.cwvlug_public_sn_rt_01.id}"
}

resource "aws_subnet" "cwvlug_public_sn_02" {
  vpc_id      = "${aws_vpc.cwvlug_vpc.id}"
  cidr_block  = "${var.aws_vpc_public_sn_02_cidr_block}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  
  tags = {
    Name = "CWVLug_Public_SN"
  }
}

resource "aws_route_table" "cwvlug_public_sn_rt_02" {
  vpc_id = "${aws_vpc.cwvlug_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.cwvlug_ig.id}"
  }
  
  tags = {
    Name = "CWVLug_Public_SN_RT"
  }
}

# Associate the routing table to public subnet 2
resource "aws_route_table_association" "cwvlug_public_sn_rt_02_assn" {
  subnet_id = "${aws_subnet.cwvlug_public_sn_02.id}"
  route_table_id = "${aws_route_table.cwvlug_public_sn_rt_02.id}"
}

resource "aws_security_group" "cwvlug_public_sg" {
  name = "cwvlug_public_sg"
  description = "Public access security group"
  vpc_id = "${aws_vpc.cwvlug_vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = [
      "${var.aws_vpc_public_sn_01_cidr_block}", "${var.aws_vpc_public_sn_02_cidr_block}"]
  }

  egress {
    # allow all traffic to private SN
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "cwvlug_public_sg"
  }
}