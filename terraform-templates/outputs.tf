output "vpc_id" {
  description = "VPC ID"
  value = "${module.vpc.vpc_id}"
}

output "rds_endpoint" {
    description = "RDS Endpoint"
    value = "${module.rds.rds_endpoint}"
}
