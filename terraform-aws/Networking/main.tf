# --- networking/main.tf ---
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
}

resource "aws_subnet" "luit_public_subnet" {
    count = length(var.public_cidrs)
    vpc_id = aws_vpc.luit_vpc.id
    cidr_block = var.public_cidrs[count.index]
    map_public_ip_on_launch = true
    availability_zone = ["us-east-1a", "us-east-1b", "us-east-1c"][count.index]
    
    tags = {
        Name = "luit_public_subnet_${count.index + 1}"
    }
}