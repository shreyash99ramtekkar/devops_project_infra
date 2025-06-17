output "bastion_host" {
  description = "tomcat-public-ip-1"
  value       = aws_instance.db_bastion.public_ip
}
output "mysql_address" {
  description = "mysql-public-ip"
  value       = aws_db_instance.mysql-db.address
}
output "memcached_arn" {
  description = "memcached-address"
  value       = aws_elasticache_cluster.memcached-cluster.cluster_address

}
output "rabbitmq_arn" {
  description = "rabbitmq-arn"
  value       = aws_mq_broker.rabbitmq.instances
}

output "lb_dns_name" {
  description = "lb-dns-name"
  value       = aws_elastic_beanstalk_environment.eb_env_tomcat-env.load_balancers
}
