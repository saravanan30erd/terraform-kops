variable "project_name" {
  description = "Name of the project will be used to set prefix for resources name"
  default = "saravanan-codetest"
}

variable "global_tags" {
  description = "This tags will be added to all resources created by this script"
  type = "map"
  default = {
    "Managed_By" = "Terraform"
  }
}
