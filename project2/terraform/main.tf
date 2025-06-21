provider "aws" {
  region = var.region
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"] # Amazon Linux 2 AMI (HVM), SSD Volume Type
  filter {
    name   = "image-id"
    values = ["ami-03d8b47244d950bbb"]
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/24"
  tags = merge(var.tags, {
    Name = "vpc-${var.region}-${var.env}-${var.app_name}-vpc"
  })
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {
    Name = "igw-${var.region}-${var.env}-${var.app_name}"
  })
}
resource "aws_subnet" "public-app-subnet-1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/26"
  availability_zone = "${var.region}a"
  tags = merge(var.tags, {
    Name = "subnet-pub-${var.region}a-${var.env}-${var.app_name}"
  })
}

resource "aws_subnet" "public-app-subnet-2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.64/26"
  availability_zone = "${var.region}b"
  tags = merge(
    var.tags,
    {
      Name = "subnet-pub-${var.region}b-${var.env}-${var.app_name}"
    }
  )
}
resource "aws_subnet" "private-db-subnet-3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.128/26"
  availability_zone = "${var.region}c"
  tags = merge(
    var.tags,
    {
      Name = "subnet-pri-${var.region}c-${var.env}-${var.app_name}"
    }
  )
}
resource "aws_subnet" "private-db-subnet-4" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.192/26"
  availability_zone = "${var.region}a"
  tags = merge(
    var.tags,
    {
      Name = "subnet-pri-${var.region}a-${var.env}-${var.app_name}"
    }
  )
}


resource "aws_route_table" "rt-public" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.tags,
    {
      Name = "rtb-${var.region}-${var.env}-${var.app_name}"
    }
  )
}

resource "aws_route" "public-internet-access" {
  route_table_id         = aws_route_table.rt-public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main-igw.id
}
resource "aws_route_table_association" "web-app-public-subnet-1" {
  subnet_id      = aws_subnet.public-app-subnet-1.id
  route_table_id = aws_route_table.rt-public.id
}
resource "aws_route_table_association" "web-app-public-subnet-2" {
  subnet_id      = aws_subnet.public-app-subnet-2.id
  route_table_id = aws_route_table.rt-public.id
}

# resource "aws_route_table_association" "web-db-public-subnet-3" {
#   subnet_id      = aws_subnet.public-db-subnet-3.id
#   route_table_id = aws_route_table.rt-public.id
# }
# resource "aws_route_table_association" "web-db-public-subnet-4" {
#   subnet_id      = aws_subnet.public-db-subnet-4.id
#   route_table_id = aws_route_table.rt-public.id
# }


resource "aws_security_group" "sg-backend-db" {
  name        = "sg.backend.db.${var.region}.${var.env}.${var.app_name}"
  description = "Security group for backend instances"
  vpc_id      = aws_vpc.main.id
  tags = merge(
    var.tags,
    {
      Name = "sg-backend-db-${var.region}-${var.env}-${var.app_name}"
    }
  )
}
# Backend database security group allowing communication between each other 
resource "aws_vpc_security_group_ingress_rule" "sgr-backend-ingress-db" {
  security_group_id            = aws_security_group.sg-backend-db.id
  referenced_security_group_id = aws_security_group.sg-backend-db.id
  ip_protocol                  = "-1"
  description                  = "Allow all TCP services within the backend security group"
}
# Backend database security group allowing communication between each other 
resource "aws_vpc_security_group_egress_rule" "sgr-backend-egress-db" {
  security_group_id = aws_security_group.sg-backend-db.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all TCP services within the backend security group"
}

resource "aws_security_group" "sg-bastion-db" {
  name        = "sg.bastion.db.${var.region}.${var.env}.${var.app_name}"
  description = "Security group for bastion instances"
  vpc_id      = aws_vpc.main.id
  tags = merge(
    var.tags,
    {
      Name = "sg-bastion-db-${var.region}-${var.env}-${var.app_name}"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "sgr-bastion-db" {
  security_group_id = aws_security_group.sg-bastion-db.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "TCP"
  cidr_ipv4         = "${var.my_ip}/32"
  description       = "Allow SSH access from my IP"
}
resource "aws_vpc_security_group_egress_rule" "allow_outbound_ipv4" {
  security_group_id = aws_security_group.sg-bastion-db.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Security group for Elastic Beanstalk Load Balancer 
resource "aws_security_group" "sg-beanstalk-lb" {
  name        = "sg.beanstalk.lb.${var.region}.${var.env}.${var.app_name}"
  description = "Security group for Elastic Beanstalk Load Balancer"
  vpc_id      = aws_vpc.main.id
  tags = merge(
    var.tags,
    {
      Name = "sg-beanstalk-lb-${var.region}-${var.env}-${var.app_name}"
    }
  )
}


resource "aws_vpc_security_group_ingress_rule" "ingress-beanstalk-lb-http" {
  security_group_id = aws_security_group.sg-beanstalk-lb.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "TCP"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow HTTP traffic from anywhere"
}
resource "aws_vpc_security_group_egress_rule" "egress-beanstalk-lb-http" {
  security_group_id = aws_security_group.sg-beanstalk-lb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "TCP"
  from_port         = 443
  to_port           = 443
  description       = "Allow HTTP traffic to anywhere"
}

# Security group for Elastic Beanstalk EC2 instances
resource "aws_security_group" "sg-beanstalk-ec2" {
  name        = "sg.beanstalk.ec2.${var.region}.${var.env}.${var.app_name}"
  description = "Security group for Elastic Beanstalk EC2 instances"
  vpc_id      = aws_vpc.main.id
  tags = merge(
    var.tags,
    {
      Name = "sg-beanstalk-ec2-${var.region}-${var.env}-${var.app_name}"
    }
  )
}
resource "aws_vpc_security_group_egress_rule" "egress-beanstalk-ec2-http" {
  security_group_id = aws_security_group.sg-beanstalk-ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow HTTP traffic to anywhere"

}

resource "aws_vpc_security_group_ingress_rule" "ingress-beanstalk-ec2-http" {
  security_group_id            = aws_security_group.sg-beanstalk-ec2.id
  referenced_security_group_id = aws_security_group.sg-beanstalk-lb.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "TCP"
  description                  = "Allow HTTP traffic from lb"
}


resource "aws_vpc_security_group_ingress_rule" "sgr-ec2-backend-db" {
  security_group_id            = aws_security_group.sg-backend-db.id
  referenced_security_group_id = aws_security_group.sg-beanstalk-ec2.id
  ip_protocol                  = "-1"
  description                  = "Allow all TCP services within the backend security group"
}

# Backend database security group allowing communication between each other 
resource "aws_vpc_security_group_ingress_rule" "sgr-backend-db-mysql" {
  security_group_id            = aws_security_group.sg-backend-db.id
  referenced_security_group_id = aws_security_group.sg-bastion-db.id
  ip_protocol                  = "TCP"
  from_port                    = 3306
  to_port                      = 3306
  description                  = "Allow all TCP services within the backend security group"
}

resource "aws_db_parameter_group" "rds-mysql-pg" {
  name        = "rds-mysql-pg-${var.region}-${var.env}-${var.app_name}"
  family      = "mysql8.0"
  description = "MySQL parameter group for ${var.app_name}"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
  tags = merge(
    var.tags,
    {
      Name = "rds-mysql-pg-${var.region}-${var.env}-${var.app_name}"
    }
  )
}

resource "aws_db_subnet_group" "rds-mysql-subnet-grp" {
  name        = "rds-mysql-subnet-group-${var.region}-${var.env}-${var.app_name}"
  subnet_ids  = [aws_subnet.private-db-subnet-3.id, aws_subnet.private-db-subnet-4.id]
  description = "MySQL subnet group for ${var.app_name}"
  tags = merge(
    var.tags,
    {
      Name = "rds-mysql-subnet-group-${var.region}-${var.env}-${var.app_name}"
    }
  )
}

resource "aws_db_instance" "mysql-db" {
  identifier        = "rds-mysql-${var.region}-${var.env}-${var.app_name}"
  engine            = "mysql"
  engine_version    = "8.0.42"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  # storage_type           = "gp3"
  username               = "admin"
  password               = var.db_password # Change this to a secure password
  vpc_security_group_ids = [aws_security_group.sg-backend-db.id]
  db_subnet_group_name   = aws_db_subnet_group.rds-mysql-subnet-grp.name
  parameter_group_name   = aws_db_parameter_group.rds-mysql-pg.name
  skip_final_snapshot    = true
  # enabled_cloudwatch_logs_exports 
  tags = merge(
    var.tags,
    {
      Name = "rds-mysql-${var.region}-${var.env}-${var.app_name}"
    }
  )
}

resource "aws_elasticache_parameter_group" "memcached-pg" {
  name        = "memcached-pg-${var.region}-${var.env}-${var.app_name}"
  family      = "memcached1.6"
  description = "Memcached parameter group for ${var.app_name}"
  tags = merge(
    var.tags,
    {
      Name = "memcached-pg-${var.region}-${var.env}-${var.app_name}"
    }
  )
}

resource "aws_elasticache_subnet_group" "memcached-subnet-grp" {
  name        = "subnet-grp-memcached-${var.region}-${var.env}-${var.app_name}"
  subnet_ids  = [aws_subnet.private-db-subnet-3.id, aws_subnet.private-db-subnet-4.id]
  description = "Memcached subnet group for ${var.app_name}"
  tags = merge(
    var.tags,
    {
      Name = "subnet-grp-memcached-${var.region}-${var.env}-${var.app_name}"
    }
  )
}

resource "aws_elasticache_cluster" "memcached-cluster" {
  cluster_id           = "memcached-cluster-${var.region}-${var.env}-${var.app_name}"
  engine_version       = "1.6.22"
  engine               = "memcached"
  node_type            = "cache.t2.micro"
  subnet_group_name    = aws_elasticache_subnet_group.memcached-subnet-grp.name
  security_group_ids   = [aws_security_group.sg-backend-db.id]
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.memcached-pg.name
  port                 = 11211
}

resource "aws_mq_broker" "rabbitmq" {
  apply_immediately          = true
  broker_name                = "rabbitmq-${var.region}-${var.env}-${var.app_name}"
  deployment_mode            = "SINGLE_INSTANCE"
  engine_type                = "RabbitMQ"
  engine_version             = "3.13"
  host_instance_type         = "mq.t3.micro"
  auto_minor_version_upgrade = true
  publicly_accessible        = false
  security_groups            = [aws_security_group.sg-backend-db.id]
  subnet_ids                 = [aws_subnet.private-db-subnet-3.id]
  user {
    username = "admin"
    password = var.db_password
  }
  tags = merge(
    var.tags,
    {
      Name = "rabbitmq-${var.region}-${var.env}-${var.app_name}"
    }
  )
}

resource "aws_instance" "db_bastion" {
  depends_on                  = [aws_db_instance.mysql-db]
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  key_name                    = var.key_pair
  subnet_id                   = aws_subnet.public-app-subnet-1.id
  vpc_security_group_ids      = [aws_security_group.sg-bastion-db.id]
  associate_public_ip_address = true
  tags = merge(
    var.tags,
    {
      Name = "db-bastion-${var.region}-${var.env}-${var.app_name}"
    }
  )
}
resource "aws_iam_role" "elastic_beanstalk_service_role" {
  name = "beanstalk-service-${var.region}-${var.env}-${var.app_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "elasticbeanstalk.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "beanstalk_service_role_policy" {
  role       = aws_iam_role.elastic_beanstalk_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}
resource "aws_iam_role_policy_attachment" "beanstalk_service_role_policy2" {
  role       = aws_iam_role.elastic_beanstalk_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}



resource "aws_iam_role" "beanstalk_instance_profile_role" {
  name = "iam-role-beanstalk-ec2-${var.region}-${var.env}-${var.app_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "admin_access_beanstalk_tomcat" {
  role       = aws_iam_role.beanstalk_instance_profile_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-AWSElasticBeanstalk"
}
resource "aws_iam_role_policy_attachment" "custom_platform_beanstalk_tomcat" {
  role       = aws_iam_role.beanstalk_instance_profile_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkCustomPlatformforEC2Role"
}
resource "aws_iam_role_policy_attachment" "sns_beanstalk_tomcat" {
  role       = aws_iam_role.beanstalk_instance_profile_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkRoleSNS"
}
resource "aws_iam_role_policy_attachment" "web_tier_beanstalk_tomcat" {
  role       = aws_iam_role.beanstalk_instance_profile_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_instance_profile" "beanstalk_instance_profile_role" {
  name = "iam-profile-beanstalk-ec2-${var.region}-${var.env}-${var.app_name}"
  role = aws_iam_role.beanstalk_instance_profile_role.name
  tags = merge(
    var.tags,
    {
      Name = "iam-profile-beanstalk-ec2-${var.region}-${var.env}-${var.app_name}"
    }
  )
}




resource "aws_elastic_beanstalk_application" "eb_tomcat_app" {
  name        = "eb-web-app-${var.region}-${var.env}-${var.app_name}"
  description = "Elastic Beanstalk application for Tomcat"
  appversion_lifecycle {
    service_role = aws_iam_role.elastic_beanstalk_service_role.arn

  }
  tags = merge(
    var.tags,
    {
      Name = "web-app-${var.region}-${var.env}-${var.app_name}"
    }
  )
}

resource "aws_elastic_beanstalk_environment" "eb_env_tomcat-env" {
  name                = "eb-env-${var.region}-${var.env}-${var.app_name}"
  application         = aws_elastic_beanstalk_application.eb_tomcat_app.name
  description         = "Elastic Beanstalk environment for Tomcat application"
  tier                = "WebServer"
  cname_prefix        = "vprofile-web-app"
  solution_stack_name = "64bit Amazon Linux 2023 v5.6.2 running Tomcat 10 Corretto 21"
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.beanstalk_instance_profile_role.name
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = var.key_pair # e.g., "my-eb-key"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeType"
    value     = "gp3"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.sg-beanstalk-ec2.id
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application" # <- Make sure it's a valid number as a string
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.main.id
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${aws_subnet.public-app-subnet-1.id},${aws_subnet.public-app-subnet-2.id}"

  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "public"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "true"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = "${aws_subnet.public-app-subnet-1.id},${aws_subnet.public-app-subnet-2.id}"
  }


  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "2"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "4"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "MeasureName"
    value     = "CPUUtilization"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Unit"
    value     = "Percent"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperThreshold"
    value     = "70"
  }




  # Disable HTTP
  setting {
    namespace = "aws:elbv2:listener:default"
    name      = "ListenerEnabled"
    value     = "false"
  }

  # Enable HTTPS listener on port 443
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "ListenerEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "Protocol"
    value     = "HTTPS"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLCertificateArns"
    value     = var.cert_arn
  }
  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "SecurityGroups"
    value     = aws_security_group.sg-beanstalk-lb.id
  }




  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "StickinessEnabled"
    value     = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateEnabled"
    value     = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "Rolling"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSizeType"
    value     = "Percentage"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "DisableDefaultEC2SecurityGroup"
    value     = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSize"
    value     = "50"
  }
  tags = merge(
    var.tags,
    {
      Name = "web-app-env-${var.region}-${var.env}-${var.app_name}"
    }
  )

}

resource "aws_s3_bucket" "application_bucket" {
  bucket = "beanstalk-${var.region}-${var.env}-${var.app_name}-bucket"
  tags = merge(
    var.tags,
    {
      Name = "beanstalk-bucket-${var.region}-${var.env}-${var.app_name}"
    }
  )
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_object" "default_app" {
  bucket = aws_s3_bucket.application_bucket.id
  key    = "beanstalk/tomcat.zip"
  source = "tomcat.zip"
}

resource "aws_elastic_beanstalk_application_version" "application_version" {
  name        = "vprofile-web-app-${var.region}-${var.env}-${var.app_name}-v1"
  application = aws_elastic_beanstalk_application.eb_tomcat_app.name
  description = "Version 1 of the vProfile web application"
  bucket      = aws_s3_bucket.application_bucket.id
  key         = aws_s3_object.default_app.key
  lifecycle {
    create_before_destroy = true
  }
  tags = merge(
    var.tags,
    {
      Name = "web-app-version-${var.region}-${var.env}-${var.app_name}"
    }
  )

}


resource "aws_cloudfront_distribution" "web_app_distribution" {
  origin {
    domain_name = aws_elastic_beanstalk_environment.eb_env_tomcat-env.endpoint_url
    origin_id   = "ElasticBeanstalkOrigin"
    custom_origin_config {
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
      https_port             = 443
      http_port              = 80
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = ""


  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ElasticBeanstalkOrigin"

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  aliases = ["vprofile.devops-projects.tech"]


  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "IN", "DE", "IE"]
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "web-app-distribution-${var.region}-${var.env}-${var.app_name}"
    }
  )

  viewer_certificate {
    acm_certificate_arn      = var.cert_arn_cloudfront
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
