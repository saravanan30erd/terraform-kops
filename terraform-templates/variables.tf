variable "project_name" {
  description = "Name of the project will be used to set prefix for resources name"
  default = "saravanan-wordpress"
}

variable "global_tags" {
  description = "This tags will be added to all resources created by this script"
  type = "map"
  default = {
    "Managed_By" = "Terraform"
  }
}

variable "database_username" {
  default = "wordpress"
}

variable "database_password" {
  default = "wordpress"
}

variable "database_name" {
  default = "wordpress"
}
