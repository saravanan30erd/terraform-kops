output "vpc_id" {
  description = "VPC ID"
  value = "${aws_vpc.default_vpc.id}"
}

output "public_subnets" {
  description = "List of the Public subnet IDs"
  value = "${aws_subnet.public_sub.*.id}"
}

output "private_subnets" {
  description = "List of the Private subnet IDs"
  value = "${aws_subnet.private_sub.*.id}"
}

output "nat_gateway_ids" {
  description = "List of the NAT Gateway IDs"
  value = "${aws_nat_gateway.nat_gateway.*.id}"
}
