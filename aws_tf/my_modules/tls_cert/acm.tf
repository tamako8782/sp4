
variable "domain_name" {
    type = string
}
variable "route53_zone_id" {
    type = string
}


resource "aws_acm_certificate" "acm_certificate" {
    provider = aws.acm-region
    domain_name = var.domain_name
    validation_method = "DNS"
    //subject_alternative_names = ["*.${var.domain_name}"]
}

resource "aws_route53_record" "acm_certificate_validation_record" {
    provider = aws.acm-region
    for_each = {
        for dvo in aws_acm_certificate.acm_certificate.domain_validation_options : dvo.domain_name => {
            name = dvo.resource_record_name
            record = dvo.resource_record_value
            type = dvo.resource_record_type
        }
    }
    
    allow_overwrite = true
    name = each.value.name
    zone_id = var.route53_zone_id
    type = each.value.type
    records = [each.value.record]
    ttl = 300


}

resource "aws_acm_certificate_validation" "acm_certificate_validation" {
    provider = aws.acm-region
    certificate_arn = aws_acm_certificate.acm_certificate.arn
    validation_record_fqdns = [for dvo in aws_route53_record.acm_certificate_validation_record : dvo.fqdn]
}

output "acm_certificate_arn" {
    value = aws_acm_certificate.acm_certificate.arn
}

