##############################################
# Route53 module outputs - outputs.tf        #
##############################################

output "certificate_arn" { value = aws_acm_certificate.app_cert.arn }
output "certificate_validation" { value = aws_acm_certificate_validation.app_cert_validation }
output "app_url" { value = "https://${var.subdomain}.${var.root_domain_name}" }
