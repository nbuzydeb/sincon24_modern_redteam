# Core Networking

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.100.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "MyVPC"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyInternetGateway"
  }
}

resource "aws_subnet" "my_private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.100.1.0/24"
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "MyPrivateSubnet"
  }
}

resource "aws_subnet" "my_public_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.100.2.0/24"
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "MyPublicSubnet1"
  }
}

resource "aws_subnet" "my_public_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.100.3.0/24"
  availability_zone = "ap-southeast-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "MyPublicSubnet2"
  }
}

resource "aws_eip" "nat_eip" {
}

resource "aws_nat_gateway" "my_nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.my_public_subnet_1.id
  tags = {
    Name = "MyNATGateway"
  }
  depends_on = [aws_internet_gateway.my_igw]
}

resource "aws_route_table" "my_public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "MyPublicRouteTable"
  }
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.my_public_subnet_1.id
  route_table_id = aws_route_table.my_public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.my_public_subnet_2.id
  route_table_id = aws_route_table.my_public_route_table.id
}

resource "aws_route_table" "my_private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gw.id
  }
  tags = {
    Name = "MyPrivateRouteTable"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.my_private_subnet.id
  route_table_id = aws_route_table.my_private_route_table.id
}