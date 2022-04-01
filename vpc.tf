provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "test-vpc"
  }

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "test-igw"
  }
}


resource "aws_subnet" "private-a" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "private-a"
  }
}

resource "aws_subnet" "private-b" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2b"
  tags = {
    Name = "private-b"
  }
}

resource "aws_subnet" "public-a" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "public-a"
  }
}

resource "aws_subnet" "public-b" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-2b"
  tags = {
    Name = "public-b"
  }
}

resource "aws_eip" "nat_eip_1" {
  vpc = true
}
resource "aws_eip" "nat_eip_2" {
  vpc = true
}

resource "aws_nat_gateway" "private-NAT-a" {
  allocation_id = aws_eip.nat_eip_1.id
  subnet_id = aws_subnet.public-a.id
  tags = {
    "Name" = "private-NAT-a"
  }
}

resource "aws_nat_gateway" "private-NAT-b" {
  allocation_id = aws_eip.nat_eip_2.id
  subnet_id = aws_subnet.public-b.id
  tags = {
    "Name" = "private-NAT-b"
  }
}

resource "aws_default_route_table" "public_rt" {
    default_route_table_id = aws_vpc.vpc.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "public-rt"
    }
}



resource "aws_route_table_association" "public-a" {
    subnet_id      = aws_subnet.public-a.id
    route_table_id = aws_default_route_table.public_rt.id
}

resource "aws_route_table_association" "public-b" {
    subnet_id      = aws_subnet.public-b.id
    route_table_id = aws_default_route_table.public_rt.id
}


resource "aws_route_table" "private_rt_a" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "private-rt-a"
    }
}

resource "aws_route_table" "private_rt_b" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "private-rt-b"
    }
}


resource "aws_route_table_association" "private_rta_a" {
    subnet_id      = aws_subnet.private-a.id
    route_table_id = aws_route_table.private_rt_a.id
}


resource "aws_route_table_association" "private_rta_b" {
    subnet_id      = aws_subnet.private-b.id
    route_table_id = aws_route_table.private_rt_b.id
}


resource "aws_route" "private_rt_route_a" {
    route_table_id              = aws_route_table.private_rt_a.id
    destination_cidr_block      = "0.0.0.0/0"
    nat_gateway_id              = aws_nat_gateway.private-NAT-a.id
}

resource "aws_route" "private_rt_route_b" {
    route_table_id              = aws_route_table.private_rt_b.id
    destination_cidr_block      = "0.0.0.0/0"
    nat_gateway_id              = aws_nat_gateway.private-NAT-b.id
}