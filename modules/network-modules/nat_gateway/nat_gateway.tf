resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "NAT EIP"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  subnet_id = var.public_subnet_ids[0]
  allocation_id = aws_eip.nat_eip.allocation_id
  tags = {
    Name = "my-nat-gateway"
  }
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gateway.id
}