terraform {
  required_version = "~> 0.11.5"
}

provider "aws" {
  version = "~> 1.12"
  region = "eu-west-1"
}

module "vpc" {
  source = "./modules/vpc"

  prefix = "${var.project_name}"
  cidr = "10.10.0.0/16"
  enable_dns_hostnames = true
  tags = "${var.global_tags}"
  azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  public_subnets = ["10.10.4.0/24", "10.10.5.0/24", "10.10.6.0/24"]
  multi_az_nat_gateway = false
}

module "rds" {
  source = "./modules/rds"

  prefix = "${var.project_name}"
  tags = "${var.global_tags}"
  rds_vpc_id = "${module.vpc.vpc_id}"
  private_subnets = "${module.vpc.private_subnets}"
  database = "${var.database_name}"
  username = "${var.database_username}"
  password = "${var.database_password}"
}
