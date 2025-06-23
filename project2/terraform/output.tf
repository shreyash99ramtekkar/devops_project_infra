output "bastion_host" {
  description = "tomcat-public-ip-1"
  value       = aws_instance.db_bastion.public_ip
}
output "mysql_address" {
  description = "mysql-public-ip"
  value       = aws_db_instance.mysql-db.address
}
output "memcached_address" {
  description = "memcached-address"
  value       = aws_elasticache_cluster.memcached-cluster.cluster_address

}
output "rabbitmq_endpoint" {
  description = "rabbitmq-endpoint"
  value       = aws_mq_broker.rabbitmq.instances
}

output "lb_dns_name" {
  description = "lb-dns-name"
  value       = aws_elastic_beanstalk_environment.eb_env_tomcat-env.load_balancers
}

# output "distribution_domain_name" {
#   description = "distribution-domain-name"
#   value       = aws_cloudfront_distribution.web_app_distribution.domain_name

# }