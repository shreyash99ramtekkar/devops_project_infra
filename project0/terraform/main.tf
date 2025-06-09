resource "aws_acm_certificate" "web-app-cert" {
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"
  key_algorithm     = "RSA_2048"
  tags = merge(
    var.tags,
    {
      Name = "ACM Certificate for ${var.domain_name}"
    }
  )
}