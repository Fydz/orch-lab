# ---------------------------------------------------------------
data "aws_elastic_beanstalk_solution_stack" "php71" {
  most_recent   = true
  name_regex    = "^64bit Amazon Linux (.*) PHP 7.1$"
}

# ---------------------------------------------------------------
resource "aws_elastic_beanstalk_environment" "eb-env" {
  name                = "env-${var.env}"
  application         = "${aws_elastic_beanstalk_application.eb-app.name}"
  solution_stack_name = "${data.aws_elastic_beanstalk_solution_stack.php71.name}"
   
  # ------ autoscaling --------------------------------------------- 
  setting {
    namespace = "aws:autoscaling:asg"
    name = "MinSize"
    value = "1"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "MaxSize"
    value = "1"
  }
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name = "RollingUpdateEnabled"
    value = "false"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "DeploymentPolicy"
    value = "AllAtOnce"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "IgnoreHealthCheck"
    value = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:monitoring"
    name = "Automatically Terminate Unhealthy Instances"
    value = "false"
  }
    
  # --------------------------------------------------------------- 
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "t2.micro"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile"
    value = "aws-elasticbeanstalk-ec2-role"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "EC2KeyName"
    value = "${aws_key_pair.alex.id}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "SSHSourceRestriction"
    value = "tcp, 22, 22, 109.2.147.103/25"
  }

  # --------------------------------------------------------------- 
  setting {
    namespace = "aws:ec2:vpc"
    name = "VPCId"
    value = "${aws_vpc.vpc.id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "Subnets"
    value = "${aws_subnet.main-a.id},${aws_subnet.main-b.id},${aws_subnet.main-c.id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBSubnets"
    value = "${aws_subnet.main-a.id},${aws_subnet.main-b.id},${aws_subnet.main-c.id}"
  }
  # --------------------------------------------------------------- 

  # ---------------------------------------------------------------
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_HOSTNAME"
    value = "${aws_rds_cluster.rds-cluster.endpoint}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_PORT"
    value = "${aws_rds_cluster.rds-cluster.port}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_DB_NAME"
    value = "${aws_rds_cluster.rds-cluster.database_name}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_USERNAME"
    value = "${aws_rds_cluster.rds-cluster.master_username}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_PASSWORD"
    value = "${aws_rds_cluster.rds-cluster.master_password}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "HASH_SALT"
    value = "${random_id.salt.b64_std}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "SYNC_DIR"
    value = "sites/default/files/config_${random_id.config_dir.b64_url}/sync"
  }
  # ---------------------------------------------------------------

  # --------------------------------------------------------------- 
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "AWS_KID"
    value = "${aws_iam_access_key.eb-s3-user-key.id}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "AWS_KEY"
    value = "${aws_iam_access_key.eb-s3-user-key.secret}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "S3_BUCKET"
    value = "${aws_s3_bucket.s3.id}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name = "DeleteOnTerminate"
    value = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name = "DeleteOnTerminate"
    value = "true"
  }
  # --------------------------------------------------------------- 


  tags = {
    "environment" = "${var.env}"
    "application" = "${var.app}"
    "client" = "${var.customer}"
  }
}

# ---------------------------------------------------------------
resource "aws_elastic_beanstalk_application" "eb-app" {
  name        = "app-${var.app}"
  description = "${var.app}"
  
  appversion_lifecycle {
    service_role          = "arn:aws:iam::484955276991:role/aws-elasticbeanstalk-service-role"
    max_count             = 16
    delete_source_from_s3 = true
  }
}

data "aws_security_group" "AWSEBSecurityGroup" {
  vpc_id = "${aws_vpc.vpc.id}"
  filter {
    name   = "group-name"
    values = ["*AWSEBSecurityGroup*"]
  }
  
  depends_on = ["aws_elastic_beanstalk_application.eb-app", 
                "aws_elastic_beanstalk_environment.eb-env"]
}

output "eb-cname" {
  value = "${aws_elastic_beanstalk_environment.eb-env.cname}"
}

data "aws_instance" "eb-ec2" {
  filter {
    name   = "tag:environment"
    values = ["${var.env}"]
  }
  
  filter {
    name   = "tag:application"
    values = ["${var.app}"]
  }
  
  filter {
    name   = "tag:client"
    values = ["${var.customer}"]
  }

  filter {
    name   = "vpc-id"
    values = ["${aws_vpc.vpc.id}"]
  }
  
  depends_on = ["aws_elastic_beanstalk_application.eb-app", 
                "aws_elastic_beanstalk_environment.eb-env"]
}

output "eb-ec2-public-ip" {
  value = "${data.aws_instance.eb-ec2.public_ip}"
}
