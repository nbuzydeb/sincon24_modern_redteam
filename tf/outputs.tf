# C2 Cloudfront Redirector URL
output "mythic_v3_cloudfront_distribution" {
  value = format("https://%s", aws_cloudfront_distribution.aws_cdn_mythic_v3.domain_name)
}

# Mythic C2 instance ID
output "mythic_v3_instance_id" {
  value = aws_instance.mythic_v3.id
}

# Phishing server instance ID
output "phishing_instance_id" {
  value = aws_instance.phishing.id
}

# Phishing server public IP
output "phishing_server_IP" {
  value = aws_instance.phishing.public_ip
}