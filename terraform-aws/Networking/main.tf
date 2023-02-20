# --- networking/main.tf ---

data "aws_availability_zones" "available" {}


resource "random_integer" "random" {
    min = 1
    max = 100
}

resource "aws_vpc" "luit_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    
    tags = {
        Name = "luit_vpc-${random_integer.random.id}"
    }
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_subnet" "luit_public_subnet" {
    count = var.public_sn_count
    vpc_id = aws_vpc.luit_vpc.id
    cidr_block = var.public_cidrs[count.index]
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available.names[count.index]
    
    tags = {
        Name = "luit_public_subnet_${count.index + 1}"
    }
}

resource "aws_route_table_association" "luit_public_assoc" {
    count = var.public_sn_count
    subnet_id = aws_subnet.luit_public_subnet.*.id[count.index]
    route_table_id = aws_route_table.luit_public_rt.id
}

resource "aws_subnet" "luit_private_subnet" {
    count = var.private_sn_count
    vpc_id = aws_vpc.luit_vpc.id
    cidr_block = var.private_cidrs[count.index]
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.available.names[count.index]
    
    tags = {
        Name = "luit_private_subnet_${count.index + 1}"
    }
}

resource "aws_internet_gateway" "luit_internet_gateway" {
    vpc_id = aws_vpc.luit_vpc.id
    
    tags = {
        Name = "luit_igw"
    }
}

resource "aws_route_table" "luit_public_rt" {
    vpc_id = aws_vpc.luit_vpc.id
    
    tags = {
        Name = "luit_public"
    }
}

resource "aws_route" "default_route" {
    route_table_id = aws_route_table.luit_public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.luit_internet_gateway.id
}

resource "aws_default_route_table" "luit_private_rt" {
    default_route_table_id = aws_vpc.luit_vpc.default_route_table_id
    
    tags = {
        Name = "luit_private"
    }
}

resource "aws_security_group" "luit_sg" {
  name        = "public_luit_sg"
  description = "Public Access"
  vpc_id      = aws_vpc.luit_vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.access_ip]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}