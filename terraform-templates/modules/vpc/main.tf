
### VPC ###
resource "aws_vpc" "default_vpc" {
  cidr_block = "${var.cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"
  tags = "${merge(
    var.tags,
    map(
      "Name", format("%s-vpc", var.prefix)
    )
  )}"
}

### Internet Gateway for Public Subnets ###
resource "aws_internet_gateway" "default_internet_gateway" {
  vpc_id = "${aws_vpc.default_vpc.id}"
  tags = "${merge(
    var.tags,
    map(
      "Name", format("%s-IG", var.prefix)
    )
  )}"
}

### Route Table for Public Subnets ###
resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.default_vpc.id}"
  tags = "${merge(
    var.tags,
    map(
      "Name", format("%s-public", var.prefix)
    )
  )}"
}

### Add Route Table Entry for Internet Gateway in Public Route Table ###
resource "aws_route" "public_route_internet_gateway" {
  route_table_id = "${aws_route_table.public_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.default_internet_gateway.id}"
}

### Public Subnets ###
resource "aws_subnet" "public_sub" {
  count = "${length(var.public_subnets)}"
  vpc_id = "${aws_vpc.default_vpc.id}"
  cidr_block = "${element(var.public_subnets, count.index)}"
  availability_zone = "${element(var.azs, count.index)}"
  tags = "${merge(
    var.tags,
    map(
      "Name", format("%s-public-subnet-${count.index}", var.prefix)
    )
  )}"
}

### Associate Public Subnets with Public Route Table ###
resource "aws_route_table_association" "associate_public_sub" {
  count = "${length(var.public_subnets)}"
  subnet_id = "${element(aws_subnet.public_sub.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

# NAT Gateway is used for instances running in private subnet
# to access the internet(only outbound traffic).
# It is recommended to use NAT Gateway per Availability Zone,
# so two private subnets in two different AZ requires two NAT Gateways.
# Because If you have resources in multiple Availability Zones and they share one NAT gateway,
# in the event that NAT gateway’s Availability Zone is down,
# then resources in the other Availability Zones lose internet access.

### Private Subnets ###
resource "aws_subnet" "private_sub" {
  count = "${length(var.private_subnets)}"
  vpc_id = "${aws_vpc.default_vpc.id}"
  cidr_block = "${element(var.private_subnets, count.index)}"
  availability_zone = "${element(var.azs, count.index)}"
  tags = "${merge(
    var.tags,
    map(
      "Name", format("%s-private-subnet-${count.index}", var.prefix)
    )
  )}"
}

### Elastic IP(s) for Nat Gateway ###
resource "aws_eip" "nat_eip" {
  count = "${var.multi_az_nat_gateway ? length(var.azs) : 1}"
  vpc = true
  tags = "${merge(
    var.tags,
    map(
      "Name", format("%s-nat-gateway-%s", var.prefix, element(var.azs, (var.multi_az_nat_gateway ? count.index : 0)))
    )
  )}"
}

### Nat Gateway(s) ###
resource "aws_nat_gateway" "nat_gateway" {
  count = "${var.multi_az_nat_gateway ? length(var.azs) : 1}"
  allocation_id = "${element(aws_eip.nat_eip.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.public_sub.*.id, count.index)}"
  tags = "${merge(
    var.tags,
    map(
      "Name", format("%s-nat-gateway-%s", var.prefix, element(var.azs, (var.multi_az_nat_gateway ? count.index : 0)))
    )
  )}"
  depends_on = ["aws_internet_gateway.default_internet_gateway"]
}

### Route Table(s) for Private Subnets ###
resource "aws_route_table" "private_route_table" {
  count = "${var.multi_az_nat_gateway ? length(var.azs) : 1}"
  vpc_id = "${aws_vpc.default_vpc.id}"
  tags = "${merge(
    var.tags,
    map(
      "Name", format("%s-private-nat-gateway-%s", var.prefix, element(var.azs, (var.multi_az_nat_gateway ? count.index : 0)))
    )
  )}"
}

### Add Route Table Entry for Nat Gateway in Private Route Table(s) ###
resource "aws_route" "private_route_nat_gateway" {
  count = "${var.multi_az_nat_gateway ? length(var.azs) : 1}"
  route_table_id = "${element(aws_route_table.private_route_table.*.id, count.index)}"
  nat_gateway_id = "${element(aws_nat_gateway.nat_gateway.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
}

### Associate Private Subnets with Private Route Table(s) ###
resource "aws_route_table_association" "associate_private_sub" {
  count = "${length(var.private_subnets)}"
  subnet_id = "${element(aws_subnet.private_sub.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private_route_table.*.id, count.index)}"
}
