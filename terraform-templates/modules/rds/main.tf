resource "aws_rds_cluster_instance" "cluster_instances" {
  identifier         = "${var.cluster_name}-instance"
  cluster_identifier = "${aws_rds_cluster.cluster.id}"
  instance_class     = "${var.instance_class}"
  db_subnet_group_name  = "${aws_db_subnet_group.aurora_subnet_group.name}"
  publicly_accessible   = false
  tags = "${merge(
    var.tags,
    map(
      "Name", format("%s-rds-instance", var.prefix)
    )
  )}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster" "cluster" {
  cluster_identifier     = "${var.cluster_name}"
  database_name          = "${var.database}"
  master_username        = "${var.username}"
  master_password        = "${var.password}"
  vpc_security_group_ids = ["${aws_security_group.aurora-sg.id}"]
  skip_final_snapshot    = true
  db_subnet_group_name   = "${aws_db_subnet_group.aurora_subnet_group.name}"
  tags = "${merge(
    var.tags,
    map(
      "Name", format("%s-rds-cluster", var.prefix)
    )
  )}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_subnet_group" "aurora_subnet_group" {

    name          = "${var.cluster_name}_aurora_db_subnet_group"
    description   = "Allowed subnets for Aurora DB cluster instances"
    subnet_ids    = ["${var.private_subnets}"]

    tags = "${merge(
      var.tags,
      map(
        "Name", format("%s-rds-subnet-group", var.prefix)
      )
    )}"

}

resource "aws_security_group" "aurora-sg" {
  name   = "aurora-security-group"
  vpc_id = "${var.rds_vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = "${merge(
    var.tags,
    map(
      "Name", format("%s-rds-sg", var.prefix)
    )
  )}"
}
