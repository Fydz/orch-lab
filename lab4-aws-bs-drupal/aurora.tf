# ---------------------------------------------------------------
resource "aws_rds_cluster" "rds-cluster" {
  cluster_identifier      = "${var.env}-${var.app}-aurora-cluster"
  engine                  = "aurora"
  availability_zones      = ["${data.aws_availability_zones.available.names}"]
  
  database_name           = "${replace( "${var.env}${var.app}", "-", "" )}"
  master_username         = "${replace( "${var.env}${var.app}", "-", "" )}"
  master_password         = "${var.env}-${var.app}-${random_id.r.hex}"

  # in days
  backup_retention_period = 1
  
  preferred_backup_window = "07:00-09:00"
  preferred_maintenance_window = "sat:12:00-sat:18:00"

  # Determines whether a final DB snapshot is created before the
  # DB cluster is deleted.
  # If true is specified, no DB snapshot is created
  skip_final_snapshot     = true

  # Specifies whether any cluster modifications are 
  # applied immediately, or during the next 
  # maintenance window
  apply_immediately       = true
  
  vpc_security_group_ids = ["${aws_security_group.sql.id}"]
  db_subnet_group_name = "${aws_db_subnet_group.sql.id}"
  
  tags = {
    "environment" = "${var.env}"
    "application" = "${var.app}"
    "client" = "${var.customer}"
    Name = "${var.env}-${var.app}"
  }
}

# ---------------------------------------------------------------
resource "aws_rds_cluster_instance" "rds-instance" {
  count               = 1
  identifier          = "${var.env}-${var.app}-${count.index}"
  cluster_identifier  = "${aws_rds_cluster.rds-cluster.id}"
  instance_class      = "db.t2.small"

  publicly_accessible = false
  db_subnet_group_name = "${aws_db_subnet_group.sql.id}"
  
  # disable monitoring enhanced
  monitoring_interval = 0
  
  apply_immediately = true

  tags = {
    "environment" = "${var.env}"
    "application" = "${var.app}"
    "client" = "${var.customer}"
    Name = "${var.env}-${var.app}"
  }
}

# ---------------------------------------------------------------
resource "aws_security_group" "sql" {
  name = "sql-${var.env}-${var.app}"
  description = "${var.env}-${var.app} Aurora MySQL"
  vpc_id     = "${aws_vpc.vpc.id}"

  # Allow Aurora access from fronts
  #ingress {
  #  from_port   = 3306
  #  to_port     = 3306
  #  protocol    = "tcp"
  #
  #  self = true
  #}

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    "client" = "${var.customer}"
    Name = "Aurora MySQL"
  }
}

resource "aws_security_group_rule" "sql_add_eb_sg" {
    type        = "ingress"
    from_port   = 3306
  to_port     = 3306
    protocol    = "tcp"
    source_security_group_id = "${data.aws_security_group.AWSEBSecurityGroup.id}"
    security_group_id = "${aws_security_group.sql.id}"
    
    depends_on = ["aws_elastic_beanstalk_application.eb-app", 
                "aws_elastic_beanstalk_environment.eb-env"]
}

# ---------------------------------------------------------------
resource "aws_db_subnet_group" "sql" {
  name       = "sql-${var.env}-${var.app}"
  subnet_ids = ["${aws_subnet.main-a.id}", "${aws_subnet.main-b.id}", "${aws_subnet.main-c.id}"]

  tags = {
    "environment" = "${var.env}"
    "application" = "${var.app}"
    "client" = "${var.customer}"
    Name = "sql-${var.env}-${var.app}"
  }
}
