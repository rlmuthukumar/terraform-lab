resource "aws_vpc" "project" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.project.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.1.0/24"
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.project.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.2.0/24"
}

resource "aws_subnet" "public3" {
  vpc_id            = aws_vpc.project.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.3.0/24"
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.project.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.4.0/24"
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.project.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.5.0/24"
}

resource "aws_subnet" "private3" {
  vpc_id            = aws_vpc.project.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.6.0/24"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.project.id
}

resource "aws_route_table" "rt" {
  vpc_id = "aws_vpc.project.id"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "ra" {
  subnet_id      = "aws_subnet.public1.id"
  route_table_id = "aws_route_table.rt.id"
}

resource "aws_eip" "eip" {
  vpc = true
}
resource "aws_nat_gateway" "ngw" {
  allocation_id = "aws_eip.eip.id"
  subnet_id     = "aws_subnet.private1.id"
}

resource "aws_route_table" "rr" {
  vpc_id = aws_vpc.project.id
  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = "aws_nat_gateway.ngw.id"
  }
}
resource "aws_route_table_association" "asn" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.rr.id
}

resource "aws_instance" "web1" {
    ami             = "ami-038f1ca1bd58a5790"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.private1.id
    availability_zone = "us-east-1a"
    user_data = << EOF
		#! /bin/bash
		sudo yum update -y
		sudo yum install -y httpd
	EOF
 }

 resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "network"
  subnets            = aws_subnet.private1.id
  enable_deletion_protection = true
 }