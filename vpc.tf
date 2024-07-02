terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "SCDOA" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "my-SCDOA-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "SCDOA-public-subnet1" {
  vpc_id            = aws_vpc.SCDOA.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "my-SCDOA-public-subnet1"
  }
}

resource "aws_subnet" "SCDOA-public-subnet2" {
  vpc_id            = aws_vpc.SCDOA.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "my-SCDOA-public-subnet2"
  }
}

# Private Subnets
resource "aws_subnet" "SCDOA-private-subnet1" {
  vpc_id            = aws_vpc.SCDOA.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "my-SCDOA-private-subnet1"
  }
}

resource "aws_subnet" "SCDOA-private-subnet2" {
  vpc_id            = aws_vpc.SCDOA.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "my-SCDOA-private-subnet2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "SCDOA-gw" {
  vpc_id = aws_vpc.SCDOA.id

  tags = {
    Name = "my-SCDOA-gw"
  }
}

# Public Route Table and Association
resource "aws_route_table" "SCDOA-public-route" {
  vpc_id = aws_vpc.SCDOA.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.SCDOA-gw.id
  }

  tags = {
    Name = "my-SCDOA-public-route"
  }
}

resource "aws_route_table_association" "SCDOA-public-subnet1-association" {
  subnet_id      = aws_subnet.SCDOA-public-subnet1.id
  route_table_id = aws_route_table.SCDOA-public-route.id
}

resource "aws_route_table_association" "SCDOA-public-subnet2-association" {
  subnet_id      = aws_subnet.SCDOA-public-subnet2.id
  route_table_id = aws_route_table.SCDOA-public-route.id
}

# Private Route Table and Association
resource "aws_route_table" "SCDOA-private-route" {
  vpc_id = aws_vpc.SCDOA.id

  tags = {
    Name = "my-SCDOA-private-route"
  }
}

resource "aws_route_table_association" "SCDOA-private-subnet1-association" {
  subnet_id      = aws_subnet.SCDOA-private-subnet1.id
  route_table_id = aws_route_table.SCDOA-private-route.id
}

resource "aws_route_table_association" "SCDOA-private-subnet2-association" {
  subnet_id      = aws_subnet.SCDOA-private-subnet2.id
  route_table_id = aws_route_table.SCDOA-private-route.id
}

# NAT Gateway and Elastic IP
resource "aws_eip" "SCDOA-nat-eip" {
  vpc      = true
}

resource "aws_nat_gateway" "SCDOA-nat-gw" {
  allocation_id = aws_eip.SCDOA-nat-eip.id
  subnet_id     = aws_subnet.SCDOA-public-subnet1.id

  tags = {
    Name = "my-SCDOA-nat-gw"
  }
}

resource "aws_route" "SCDOA-private-route-out" {
  route_table_id         = aws_route_table.SCDOA-private-route.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.SCDOA-nat-gw.id
}

# Security Group
resource "aws_security_group" "SCDOA-sg" {
  vpc_id = aws_vpc.SCDOA.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-SCDOA-sg"
  }
}