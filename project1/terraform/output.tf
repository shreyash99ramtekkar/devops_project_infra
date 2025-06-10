

output "tomcat_public_ip-1" {
  description = "tomcat-public-ip-1"
  value       = aws_instance.tomcat-1.public_ip
}
output "tomcat_public_ip-2" {
  description = "tomcat-public-ip-2"
  value       = aws_instance.tomcat-2.public_ip
}
output "mysql_public_ip" {
  description = "mysql-public-ip"
  value       = aws_instance.mysql.public_ip
}
output "memcached_public_ip" {
  description = "memcached-public-ip"
  value       = aws_instance.memcached.public_ip

}
output "rabbitmq_public_ip" {
  description = "rabbitmq-public-ip"
  value       = aws_instance.rabbitmq.public_ip
}

output "lb_dns_name" {
  description = "lb-dns-name"
  value       = aws_lb.web-app-lb.dns_name
}
