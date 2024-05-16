resource "random_string" "bucket_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_s3_bucket" "redteam_logs_bucket" {
  bucket = "red-team-logs-${random_string.bucket_suffix.result}"
  force_destroy = true
}