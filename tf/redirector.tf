resource "aws_lb" "alb_c2_v3" {
  name               = "c2-alb-v3"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.my_public_subnet_1.id, aws_subnet.my_public_subnet_2.id]
  security_groups    = [aws_security_group.alb_c2_listener_sg.id]
  access_logs {
    bucket  = aws_s3_bucket.redteam_logs_bucket.id
    prefix  = "alb_v3"
    enabled = true
  }
}

resource "aws_lb_listener" "lb_listener_c2_mythic_v3" {
  load_balancer_arn = aws_lb.alb_c2_v3.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.lb_tg_c2_mythic_v3.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "lb_tg_c2_mythic_v3" {
  name        = "c2-mythic-v3-tg"
  port        = 81
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc.id
  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "lb_tg_attachment_c2_mythic_v3" {
  target_group_arn = aws_lb_target_group.lb_tg_c2_mythic_v3.arn
  target_id        = aws_instance.mythic_v3.id
  port             = 81
}

resource "aws_cloudfront_distribution" "aws_cdn_mythic_v3" {
  origin {
    domain_name = aws_lb.alb_c2_v3.dns_name
    origin_id   = aws_lb.alb_c2_v3.dns_name

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.1"]
    }
  }

  enabled         = true
  is_ipv6_enabled = false
  price_class     = "PriceClass_200"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_lb.alb_c2_v3.dns_name

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["SG"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}