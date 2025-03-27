resource "aws_subnet" "this" {
  count = length(var.subnet_configs)

  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_configs[count.index].cidr
  map_public_ip_on_launch = var.subnet_configs[count.index].public  # Public subnets get auto-assign IPs
  availability_zone = element(["ap-south-1a", "ap-south-1b"], count.index % 2)  # Spreads across 2 AZs

  tags = {
    Name = var.subnet_configs[count.index].name
  }
}
 output "private_subnet_ids" {
  value = [for i, s in aws_subnet.this : s.id if var.subnet_configs[i].public == false]
}

output "public_subnet_ids" {
  value = [for i, s in aws_subnet.this : s.id if var.subnet_configs[i].public == true]
}