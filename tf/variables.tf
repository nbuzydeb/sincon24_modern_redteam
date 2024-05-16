variable "mythic_v3_server_name" {
  default = "C2-RedTeam-Mythic-v3"
}

variable "phishing_server_name" {
  default = "Phishing-server"
}

variable "aws_profile" {
  default = "sincon2024"
}

variable "aws_region" {
  default = "ap-southeast-1"
}

variable "aws_instance_type" {
  default = "t4g.small"
}

variable "key_name" {
  default = "sincon2024"
}

variable "aws_ip_allowlist" {
  default = ["10.100.1.0/24"]
}