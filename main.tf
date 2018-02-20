data "template_file" "init" {
  template = "${file(${var.policy})}"

  vars {
    policy_name = "${var.name}${var.domain}"
  }
}

resource "aws_s3_bucket" "b" {
  bucket = "${var.name}${var.domain}"
  acl    = "public-read"
  policy = "${data.template_file.init.rendered}"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.b.bucket_domain_name}"
    origin_id   = "S3-${var.name}${var.domain}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["${var.name}${var.domain}", "www.${var.name}${var.domain}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.name}${var.domain}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags {
    Environment = "${var.name}${var.domain}"
  }

  viewer_certificate {
    acm_certificate_arn = "${var.ssl}"
    ssl_support_method  = "sni-only"
  }
}

resource "aws_route53_record" "www" {
  zone_id = "${var.zoneid}"
  name    = "www.${var.name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.s3_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "root" {
  zone_id = "${var.zoneid}"
  name    = "${var.name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.s3_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "statuscake_test" "monitoring" {
  website_name = "${aws_route53_record.root.name}${var.domain}"
  website_url  = "${aws_route53_record.root.name}${var.domain}"
  test_type    = "HTTP"
  check_rate   = 500
  contact_id   = 100705
}
