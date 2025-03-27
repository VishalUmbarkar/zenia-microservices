resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_range
  tags ={
    Name = var.vpc_name
  }
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}