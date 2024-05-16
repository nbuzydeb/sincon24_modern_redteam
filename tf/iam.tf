# EC2 instance profile creation - needed to use AWS SSM Session Manager
resource "aws_iam_role" "ssm_role" {
  name = "SSMRoleForEC2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "SSMInstanceProfile"
  role = aws_iam_role.ssm_role.name
}

# Logs S3 Bucket policy
resource "aws_s3_bucket_policy" "allow_alb_logs" {
  bucket = aws_s3_bucket.redteam_logs_bucket.id
  policy = data.aws_iam_policy_document.allow_alb_logs.json
}

# Fetch the current AWS caller identity - needed to get the AWS account ID
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "allow_alb_logs" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::114774131450:root"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.redteam_logs_bucket.arn}/alb_v3/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]
  }
}