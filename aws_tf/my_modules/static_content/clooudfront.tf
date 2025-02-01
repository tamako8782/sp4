variable "acm_certificate_arn" {
    type = string
}

variable "route53_zone_name" {
    type = string
}



resource "aws_cloudfront_distribution" "static_bucket_distribution" {
    aliases = [var.route53_zone_name]
    
    
    origin {
        domain_name = aws_s3_bucket.static_bucket.bucket_regional_domain_name
        origin_id = aws_s3_bucket.static_bucket.id

        origin_access_control_id = aws_cloudfront_origin_access_control.static_bucket_origin_access_control.id
    }
    enabled = true



    default_cache_behavior {
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = aws_s3_bucket.static_bucket.id
    
    
        forwarded_values {
            query_string = false
            headers = []
            cookies {
                forward = "none"
            }
        }
    }
    default_root_object = "index.html"

    viewer_certificate {
         acm_certificate_arn = var.acm_certificate_arn
         ssl_support_method = "sni-only"
          minimum_protocol_version = "TLSv1.2_2021" 

    }
    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }
}


resource "aws_cloudfront_origin_access_control" "static_bucket_origin_access_control" {
    name = "static-bucket-origin-access-control"
    signing_behavior = "always"
    signing_protocol = "sigv4"
    origin_access_control_origin_type = "s3"
}


output "cloudfront_distribution_arn" {
    value = aws_cloudfront_distribution.static_bucket_distribution.arn
}

output "cloudfront_distribution_domain_name" {
    value = aws_cloudfront_distribution.static_bucket_distribution.domain_name
}

output "cloudfront_distribution_zone_id" {
    value = aws_cloudfront_distribution.static_bucket_distribution.hosted_zone_id
}