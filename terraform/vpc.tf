resource "aws_vpc" "vpc" {
  cidr_block = "10.20.0.0/16"
  tags = {
    Name = "ec2_vpc"
  }
}

resource "aws_subnet" "pub_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.20.1.0/24"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.pub_subnet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sg" {
  name   = "instance_access"
  vpc_id = aws_vpc.vpc.id

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
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
