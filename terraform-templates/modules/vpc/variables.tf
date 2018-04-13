
variable "cidr" {
  description = "The default CIDR block for the VPC"
  default     = "10.0.0.0/0"
}

variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC"
  default     = false
}

variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC"
  default     = true
}

variable "tags" {
  description = "Tags to add to VPC resources"
  default = {}
}

variable "prefix" {
  description = "Name to identify all the resources"
  default     = ""
}

variable "multi_az_nat_gateway" {
  description = <<EOF
      Should be true if you want to provision NAT Gateway per AZ
      Otherwise it will provision single shared NAT Gateway for all private networks
EOF
  default = false
}

variable "azs" {
  description = "A list of availability zones in the region"
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "public_subnets" {
  description = "A list of public subnets"
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "private_subnets" {
  description = "A list of private subnets"
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
