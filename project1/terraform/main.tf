

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



resource "aws_vpc" "web-app-vpc" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-vpc"
    }
  )
}


resource "aws_internet_gateway" "ig-gw-web-app" {
  vpc_id = aws_vpc.web-app-vpc.id
  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-ig-gw"
    }
  )
}

resource "aws_subnet" "web-app-subnet-1" {
  vpc_id            = aws_vpc.web-app-vpc.id
  cidr_block        = "10.0.0.0/26"
  availability_zone = "${var.region}b"
  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-subnet-1"
    }
  )
}
resource "aws_subnet" "web-app-subnet-2" {
  vpc_id            = aws_vpc.web-app-vpc.id
  cidr_block        = "10.0.0.64/26"
  availability_zone = "${var.region}c"
  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-subnet-2"
    }
  )
}
resource "aws_subnet" "web-app-subnet-3" {
  vpc_id            = aws_vpc.web-app-vpc.id
  cidr_block        = "10.0.0.128/26"
  availability_zone = "${var.region}a"
  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-subnet-3"
    }
  )
}
resource "aws_subnet" "web-app-subnet-4" {
  vpc_id            = aws_vpc.web-app-vpc.id
  cidr_block        = "10.0.0.192/26"
  availability_zone = "${var.region}c"
  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-subnet-4"
    }
  )
}



resource "aws_route_table" "web-app-public-rt" {
  vpc_id = aws_vpc.web-app-vpc.id
  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-public-rt"
    }
  )
}

resource "aws_route" "web-app-public-internet-access" {
  route_table_id         = aws_route_table.web-app-public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig-gw-web-app.id
}

resource "aws_route_table_association" "web-app-public-subnet-1" {
  subnet_id      = aws_subnet.web-app-subnet-1.id
  route_table_id = aws_route_table.web-app-public-rt.id
}
resource "aws_route_table_association" "web-app-public-subnet-2" {
  subnet_id      = aws_subnet.web-app-subnet-2.id
  route_table_id = aws_route_table.web-app-public-rt.id
}
resource "aws_route_table_association" "web-app-public-subnet-3" {
  subnet_id      = aws_subnet.web-app-subnet-3.id
  route_table_id = aws_route_table.web-app-public-rt.id
}
resource "aws_route_table_association" "web-app-public-subnet-4" {
  subnet_id      = aws_subnet.web-app-subnet-4.id
  route_table_id = aws_route_table.web-app-public-rt.id
}

resource "aws_security_group" "web-app-elb-sg" {
  name        = "${var.app_name}-elb-sg"
  description = "Allow HTTP and HTTPS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.web-app-vpc.id
  tags = merge(
    var.tags, {
      Name = "${var.app_name}-elb-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.web-app-elb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv6" {
  security_group_id = aws_security_group.web-app-elb-sg.id
  cidr_ipv6         = "::/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
  security_group_id = aws_security_group.web-app-elb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv6" {
  security_group_id = aws_security_group.web-app-elb-sg.id
  cidr_ipv6         = "::/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_outbound_ipv4" {
  security_group_id = aws_security_group.web-app-elb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
resource "aws_vpc_security_group_egress_rule" "allow_outbound_ipv6" {
  security_group_id = aws_security_group.web-app-elb-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}



resource "aws_security_group" "web-app-tomcat-sg" {
  name        = "${var.app_name}-tomcat-sg"
  description = "Allow Tomcat inbound traffic "
  vpc_id      = aws_vpc.web-app-vpc.id
  tags = merge(
    var.tags, {
      Name = "${var.app_name}-tomcat-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "allow_tcp_tomcat" {
  security_group_id            = aws_security_group.web-app-tomcat-sg.id
  referenced_security_group_id = aws_security_group.web-app-elb-sg.id
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080
}
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_tomcat" {
  security_group_id = aws_security_group.web-app-tomcat-sg.id
  cidr_ipv4         = "${var.my_ip}/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_egress_rule" "allow_tomcat_sg_outbound_ipv4" {
  security_group_id = aws_security_group.web-app-tomcat-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
resource "aws_vpc_security_group_egress_rule" "allow_tomcat_sg_outbound_ipv6" {
  security_group_id = aws_security_group.web-app-tomcat-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}





resource "aws_security_group" "web-app-service-sg" {
  name        = "${var.app_name}-services-sg"
  description = "Allow Service inbound traffic from tomcat as well as each other inside the sg"
  vpc_id      = aws_vpc.web-app-vpc.id
  tags = merge(
    var.tags, {
      Name = "${var.app_name}-services-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "allow_tcp_mysql" {
  security_group_id            = aws_security_group.web-app-service-sg.id
  referenced_security_group_id = aws_security_group.web-app-tomcat-sg.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}

resource "aws_vpc_security_group_ingress_rule" "allow_tcp_memcached" {
  security_group_id            = aws_security_group.web-app-service-sg.id
  referenced_security_group_id = aws_security_group.web-app-tomcat-sg.id
  from_port                    = 11211
  ip_protocol                  = "tcp"
  to_port                      = 11211
}
resource "aws_vpc_security_group_ingress_rule" "allow_tcp_rabbitmq" {
  security_group_id            = aws_security_group.web-app-service-sg.id
  referenced_security_group_id = aws_security_group.web-app-tomcat-sg.id
  from_port                    = 5672
  ip_protocol                  = "tcp"
  to_port                      = 5672
}


resource "aws_vpc_security_group_ingress_rule" "allow_tcp_services" {
  security_group_id            = aws_security_group.web-app-service-sg.id
  referenced_security_group_id = aws_security_group.web-app-service-sg.id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_service_ssh_tcp_ip" {
  security_group_id = aws_security_group.web-app-service-sg.id
  cidr_ipv4         = "${var.my_ip}/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_svc_sg_outbound_ipv4" {
  security_group_id = aws_security_group.web-app-service-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
resource "aws_vpc_security_group_egress_rule" "allow_svc_sg_outbound_ipv6" {
  security_group_id = aws_security_group.web-app-service-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "tomcat" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.web-app-subnet-1.id
  count         = 2
  security_groups = [
    aws_security_group.web-app-tomcat-sg.id,
  ]
  associate_public_ip_address = true
  key_name                    = var.key_pair
  user_data                   = <<-EOF
    #!/bin/bash
    sudo dnf install java-17-amazon-corretto-devel.x86_64 -y 
    sudo useradd -r -m -U -d /opt/tomcat -s /bin/false tomcat
    wget -c https://downloads.apache.org/tomcat/tomcat-10/v10.1.41/bin/apache-tomcat-10.1.41.tar.gz
    sudo tar xf apache-tomcat-10.1.41.tar.gz -C /opt/tomcat
    sudo ln -s /opt/tomcat/apache-tomcat-10.1.41 /opt/tomcat/updated
    sudo chown -R tomcat:tomcat /opt/tomcat/*
    sh -c 'chmod +x /opt/tomcat/updated/bin/*.sh'
    sudo tee /etc/systemd/system/tomcat.service > /dev/null <<EOT
    [Unit]
    Description=Apache Tomcat Web Application Container
    After=network.target

    [Service]
    Type=forking

    Environment="JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto.x86_64"
    Environment="CATALINA_PID=/opt/tomcat/updated/temp/tomcat.pid"
    Environment="CATALINA_HOME=/opt/tomcat/updated/"
    Environment="CATALINA_BASE=/opt/tomcat/updated/"
    Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.rmi/sun.rmi.transport=ALL-UNNAMED"
    Environment="JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom"

    ExecStart=/opt/tomcat/updated/bin/startup.sh
    ExecStop=/opt/tomcat/updated/bin/shutdown.sh

    User=tomcat
    Group=tomcat
    UMask=0007
    RestartSec=10
    Restart=always

    [Install]
    WantedBy=multi-user.target
    EOT
    sudo systemctl daemon-reload
    sudo systemctl start tomcat
    sudo systemctl enable tomcat

  EOF
  tags = merge(
    var.tags, {
      Name = "Tomcat ${var.app_name}"
  })
}


resource "aws_instance" "mysql" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.web-app-subnet-1.id
  security_groups = [
    aws_security_group.web-app-service-sg.id,
  ]
  associate_public_ip_address = true
  key_name                    = var.key_pair
  user_data                   = <<-EOF
    #!/bin/bash
    DATABASE_PASS='admin123'
    sudo dnf update -y
    sudo dnf install git zip unzip -y
    sudo dnf install mariadb105-server -y
    # starting & enabling mariadb-server
    sudo systemctl start mariadb
    sudo systemctl enable mariadb
    cd /tmp/
    git clone -b main https://github.com/hkhcoder/vprofile-project.git
    #restore the dump file for the application
    sudo mysqladmin -u root password "$DATABASE_PASS"
    sudo mysql -u root -p"$DATABASE_PASS" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$DATABASE_PASS'"
    sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
    sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
    sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
    sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
    sudo mysql -u root -p"$DATABASE_PASS" -e "create database accounts"
    sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'localhost' identified by 'admin123'"
    sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'%' identified by 'admin123'"
    sudo mysql -u root -p"$DATABASE_PASS" accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql
    sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

  EOF
  tags = merge(
    var.tags, {
      Name = "MySql ${var.app_name}"
  })
}


resource "aws_instance" "memcached" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.web-app-subnet-1.id
  security_groups = [
    aws_security_group.web-app-service-sg.id,
  ]
  associate_public_ip_address = true
  key_name                    = var.key_pair
  user_data                   = <<-EOF
  #!/bin/bash
  sudo dnf install memcached -y
  sudo systemctl start memcached
  sudo systemctl enable memcached
  sudo systemctl status memcached
  sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
  sudo systemctl restart memcached
  sudo memcached -p 11211 -U 11111 -u memcached -d

  EOF
  tags = merge(
    var.tags, {
      Name = "Memcached ${var.app_name}"
  })
}

resource "aws_instance" "rabbitmq" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.web-app-subnet-1.id
  security_groups = [
    aws_security_group.web-app-service-sg.id,
  ]
  associate_public_ip_address = true
  key_name                    = var.key_pair
  user_data                   = <<-EOF
    #!/bin/bash
    ## primary RabbitMQ signing key
    rpm --import 'https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc'
    ## modern Erlang repository
    rpm --import 'https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key'
    ## RabbitMQ server repository
    rpm --import 'https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key'
    curl -o /etc/yum.repos.d/rabbitmq.repo https://raw.githubusercontent.com/hkhcoder/vprofile-project/refs/heads/awsliftandshift/al2023rmq.repo
    dnf update -y
    ## install these dependencies from standard OS repositories
    dnf install socat logrotate -y
    ## install RabbitMQ and zero dependency Erlang
    dnf install -y erlang rabbitmq-server
    systemctl enable rabbitmq-server
    systemctl start rabbitmq-server
    sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'
    sudo rabbitmqctl add_user test test
    sudo rabbitmqctl set_user_tags test administrator
    rabbitmqctl set_permissions -p / test ".*" ".*" ".*"

    sudo systemctl restart rabbitmq-server

  EOF
  tags = merge(
    var.tags, {
      Name = "Rabbitmq ${var.app_name}"
  })
}

# Route53 Private Hosted Zone and DNS Records

resource "aws_route53_zone" "private-hz" {
  name = "${var.internal_hostname}"
  comment = "Private hosted zone for ${var.app_name}"
  vpc {
    vpc_id = aws_vpc.web-app-vpc.id
  }
  tags = merge(
    var.tags, {
      Name = "Internal Route53 zone ${var.app_name}"
  })
}
resource "aws_route53_record" "mysql_dns_mapping" {
  zone_id = aws_route53_zone.private-hz.zone_id
  name    = "db.${aws_route53_zone.private-hz.name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.mysql.private_ip]
}

resource "aws_route53_record" "memcached_dns_mapping" {
  zone_id = aws_route53_zone.private-hz.zone_id
  name    = "memcached.${aws_route53_zone.private-hz.name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.memcached.private_ip]
}

resource "aws_route53_record" "rabbitmq_dns_mapping" {
  zone_id = aws_route53_zone.private-hz.zone_id
  name    = "rabbitmq.${aws_route53_zone.private-hz.name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.rabbitmq.private_ip]
}

resource "aws_route53_record" "app_dns_mapping" {
  zone_id = aws_route53_zone.private-hz.zone_id
  name    = "application.${aws_route53_zone.private-hz.name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.tomcat[1].private_ip, aws_instance.tomcat[0].private_ip]
}


# Target Group and Load Balancer
resource "aws_lb_target_group" "web-app-tg" {
  name     = "web-app-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.web-app-vpc.id
  health_check {
    port = 8080

  }
  stickiness {
    type            = "lb_cookie"
    enabled         = true
    cookie_duration = 86400 # 1 day
  }
  tags = merge(
    var.tags, {
      Name = "Target Group - ${var.app_name}"
  })
}


resource "aws_lb_target_group_attachment" "web-app-1-tg-attachment" {
  target_group_arn = aws_lb_target_group.web-app-tg.arn
  target_id        = aws_instance.tomcat[0].id
  port             = 8080
}
resource "aws_lb_target_group_attachment" "web-app-2-tg-attachment" {
  target_group_arn = aws_lb_target_group.web-app-tg.arn
  target_id        = aws_instance.tomcat[1].id
  port             = 8080
}

resource "aws_lb" "web-app-lb" {
  name               = "${var.app_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-app-elb-sg.id]
  subnets = [
    aws_subnet.web-app-subnet-1.id,
    aws_subnet.web-app-subnet-2.id,
    aws_subnet.web-app-subnet-3.id
  ]

  tags = merge(
    var.tags,
    {
      Name = "Load Balancer ${var.app_name}"
    }
  )
}

resource "aws_lb_listener" "web-app-lb-https-listener" {
  load_balancer_arn = aws_lb.web-app-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-app-tg.arn
  }
}

resource "aws_lb_listener" "web-app-lb-http-listener" {
  load_balancer_arn = aws_lb.web-app-lb.arn
  port              = "80"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn = var.cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-app-tg.arn
  }
}

# #AutoScaling Group 
# resource "aws_ami_from_instance" "web-app-ami" {
#   name               = "${var.app_name}-ami"
#   source_instance_id = aws_instance.tomcat.id
#   tags = merge(
#     var.tags, {
#       Name = "AMI for ${var.app_name}"
#   })
# }

# resource "aws_launch_template" "web-app-launch-template" {
#   name          = "${var.app_name}-launch-template"
#   description   = "Launch template for ${var.app_name} Tomcat application"
#   image_id      = aws_ami_from_instance.web-app-ami.id
#   instance_type = "t2.micro"
#   key_name      = var.key_pair
#   security_group_names = [
#     aws_security_group.web-app-tomcat-sg.name
#   ]
#   tags = merge(
#     var.tags, {
#       Name = "Launch Template for ${var.app_name}"
#   })
# }

# resource "aws_autoscaling_group" "aws-web-app-asg" {
#   name               = "${var.app_name}-asg"
#   availability_zones = [aws_subnet.web-app-subnet-1.availability_zone, aws_subnet.web-app-subnet-2.availability_zone, aws_subnet.web-app-subnet-3.availability_zone, aws_subnet.web-app-subnet-4.availability_zone]
#   desired_capacity   = 1
#   max_size           = 3
#   min_size           = 1

#   launch_template {
#     id      = aws_launch_template.web-app-launch-template.id
#     version = "$Latest"
#   }
#   load_balancers    = [aws_lb.web-app-lb.arn]
#   target_group_arns = [aws_lb_target_group.web-app-tg.arn]
#   health_check_type = "ELB"

# }

# resource "aws_autoscaling_policy" "example" {
#   autoscaling_group_name = aws_autoscaling_group.aws-web-app-asg.name
#   name                   = "${var.app_name}-scale-out-policy"
#   target_tracking_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ASGAverageCPUUtilization"
#     }
#     target_value     = 50.0
#     disable_scale_in = false
#   }

# }
