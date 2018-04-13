output "rds_endpoint" {
    value = "${aws_rds_cluster.cluster.endpoint}"
}
