output "certificate_info" {
  description = "cert-domain-info"
  value       = aws_acm_certificate.web-app-cert.domain_validation_options
}