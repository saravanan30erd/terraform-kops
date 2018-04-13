terraform {
  backend "s3" {
    bucket = "statestore.k8s.icflix.io"
    key    = "terraform/k8s-cluster.tfstate"
    region = "eu-west-1"
    encrypt = true
  }
}
