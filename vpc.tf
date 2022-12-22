data "aws_availability_zones" "available" {}

resource "aws_vpc" "eks-cluster" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name        = "${var.prefix}-eks"
    Owner       = var.prefix
    Environment = "Dev"
  }
}

resource "aws_subnet" "eks-public" {
  count = 3

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.eks-cluster.id
  tags = {
    Name                                      = "${var.prefix}-public"
    Owner                                     = var.prefix
    Environment                               = "Dev"
    Public                                    = true
    "kubernetes.io/role/elb"                  = "1"
    "kubernetes.io/cluster/${var.prefix}-eks" = "shared"
  }
}

resource "aws_internet_gateway" "eks-gateway" {
  vpc_id = aws_vpc.eks-cluster.id
  tags = {
    Name        = "${var.prefix}-eks-VPC"
    Owner       = var.prefix
    Environment = "Dev"
  }
}

resource "aws_route_table" "route-public" {
  vpc_id = aws_vpc.eks-cluster.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks-gateway.id
  }
  tags = {
    Name        = "${var.prefix}-public"
    Owner       = var.prefix
    Environment = "Dev"
    Public      = true
  }
}

resource "aws_route_table_association" "route_associate_public" {
  count          = 3
  subnet_id      = element(aws_subnet.eks-public.*.id, count.index)
  route_table_id = aws_route_table.route-public.id
}

resource "aws_subnet" "eks-private" {
  count = 3

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.1${count.index}.0/24"
  vpc_id            = aws_vpc.eks-cluster.id
  tags = {
    Name                                      = "${var.prefix}-private"
    Owner                                     = var.prefix
    Environment                               = "Dev"
    Public                                    = false
    "kubernetes.io/role/internal-elb"         = "1"
    "kubernetes.io/cluster/${var.prefix}-eks" = "shared"
  }
}

resource "aws_route_table" "route-private" {
  vpc_id = aws_vpc.eks-cluster.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks-nat-gw.id
  }
  tags = {
    Name        = "${var.prefix}-private"
    Owner       = var.prefix
    Environment = "Dev"
    Public      = false
  }
}

resource "aws_route_table_association" "route_associate_private" {
  count          = 3
  subnet_id      = element(aws_subnet.eks-private.*.id, count.index)
  route_table_id = aws_route_table.route-private.id
}

resource "aws_eip" "nat-gw-eip" {
  depends_on = [
    aws_route_table_association.route_associate_public
  ]
  vpc = true
}

resource "aws_nat_gateway" "eks-nat-gw" {
  depends_on = [
    aws_internet_gateway.eks-gateway
  ]
  allocation_id = aws_eip.nat-gw-eip.id
  subnet_id     = aws_subnet.eks-public[0].id

  tags = {
    Name        = "${var.prefix}-nat-gw"
    Owner       = var.prefix
    Environment = "Dev"
  }
}
