provider "aws" {
  region = "${var.region}"
  profile = "default"
  shared_credentials_file = "~/.aws/credentials"

}

terraform {
  backend "s3" {
  }
}
resource "aws_vpc" "production-vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

}

resource "aws_subnet" "public-subnet-1" {
  cidr_block = "${var.public_subnet_1_cidr}"
  vpc_id = "${aws_vpc.production-vpc.id}"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true

}

resource "aws_subnet" "private-subnet-1" {
  cidr_block = "${var.private_subnet_1_cidr}"
  vpc_id = "${aws_vpc.production-vpc.id}"
  availability_zone = "us-west-2a"

}


resource "aws_route_table" "public-route-table" {
  vpc_id = "${aws_vpc.production-vpc.id}"

}

resource "aws_route_table" "private-route-table" {
  vpc_id = "${aws_vpc.production-vpc.id}"

}

resource "aws_route_table_association" "public-subnet-1-association" {
  route_table_id = "${aws_route_table.public-route-table.id}"
  subnet_id = "${aws_subnet.public-subnet-1.id}"

}



resource "aws_route_table_association" "private-subnet-1-association" {
  route_table_id = "${aws_route_table.private-route-table.id}"
  subnet_id = "${aws_subnet.private-subnet-1.id}"
}



resource "aws_eip" "elastic-ip-for-nat-gw" {
  vpc = true
  #associate_with_private_ip = "10.20.1.5"
  }

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${aws_eip.elastic-ip-for-nat-gw.id}"
  subnet_id = "${aws_subnet.public-subnet-1.id}"
  depends_on = ["aws_eip.elastic-ip-for-nat-gw"]
}


resource "aws_route" "nat-gw-route" {
  route_table_id = "${aws_route_table.private-route-table.id}"
  nat_gateway_id = "${aws_nat_gateway.nat-gw.id}"
  destination_cidr_block = "0.0.0.0/0"

}

resource "aws_internet_gateway" "production-igw" {
  vpc_id = "${aws_vpc.production-vpc.id}"

}

resource "aws_route" "public-internet-gw-route" {
  route_table_id = "${aws_route_table.public-route-table.id}"
  gateway_id = "${aws_internet_gateway.production-igw.id}"
  destination_cidr_block = "0.0.0.0/0"
}


data "aws_ami" "centos" {
  owners      = ["679593333241"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAzHWaZrXvJgeY/qKY64sJ2zwrGNvzFPmWtbkf8VKuaZiqNxo+1GFUbYtbYzeXyT1kdX2VDC3lqtomouneBlAPEKAmku1YwAOVNtNjiCfAcZGHbVbJKfKv8DxKl2/Qo89LQ/LHG9dVZYP3GNInNbhG0aNgvJaqpsnrMfUPEawqLOHg8nD7SKR9dBSTe091AxppXKmpjjXj214CIxqLUcDU5FFA5u1hA7ptJcBdmVI0FZvZ4qD823tI4/W8q23kOOXk7XnRzCliS6xquifz2qMAM3jPzIRrS4T77Bil4juVQjxXqia6s6Vex2zputj2g/VxL8Oz0MDG+eZOlIsY2A1l abhijeetmohanty@Abhijeets-MBP"
}
resource "aws_instance" "my-test-instance" {
  ami             = "ami-22b9a343"
  instance_type   = "t2.micro"
  subnet_id = "${aws_subnet.public-subnet-1.id}"
  key_name = "${aws_key_pair.deployer.key_name}"

}
resource "aws_security_group" "elb" {
  name        = "elb_sg"
  description = "Used in the terraform"

  vpc_id = "${aws_vpc.production-vpc.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ensure the VPC has an Internet gateway or this step will fail
  depends_on = ["aws_internet_gateway.production-igw"]
}

resource "aws_elb" "web" {
  name = "my-elb"

  # The same availability zone as our instance
  subnets = ["${aws_subnet.private-subnet-1.id}"]

  security_groups = ["${aws_security_group.elb.id}"]

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  # The instance is registered automatically

  instances                   = ["${aws_instance.my-test-instance.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
}



resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = "${aws_vpc.production-vpc.id}"
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["${aws_subnet.public-subnet-1.cidr_block}"]

}

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}







