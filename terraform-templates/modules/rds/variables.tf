variable "cluster_name" {
  default = "wordpress-cluster"
}

variable "instance_class" {
  default = "db.t2.small"
}

variable "username" {
  default = "wordpress"
}

variable "password" {
  default = "wordpress"
}

variable "database" {
  default = "wordpress"
}

variable "tags" {
  description = "Tags to add to rds resources"
  default = {}
}

variable "private_subnets" {
  description = "List of the private subnet IDs"
  default = []
}

variable "rds_vpc_id" {
  default = ""
}

variable "prefix" {
  default = ""
}
