resource "aws_route_table" "public"{
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.gateway_id
  }
  tags = {
    Name = "public-route-table"
  }
} 
resource "aws_route_table" "private"{
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_id
  }
  tags = {
    Name = "private-route-table"
  }
} 
resource "aws_route_table_association" "rt-assoc-nat1" {
  subnet_id = var.private_subnet_ids[0]
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "rt-assoc-nat2" {
  subnet_id = var.private_subnet_ids[1]
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "rt-assoc-igw1" {
  subnet_id = var.public_subnet_ids[0]
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "rt-assoc-igw2" {
  subnet_id = var.public_subnet_ids[1]
  route_table_id = aws_route_table.public.id
}