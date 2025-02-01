variable "domain_name" {
  type = string
}

variable "route53_zone_id" {
  type = string
}

variable "alias_domain_name" {
  type = string
}

variable "alias_zone_id" {
  type = string
}

resource "aws_route53_record" "route53_record" {
    name = var.domain_name
    type = "A"
    zone_id = var.route53_zone_id
    alias {
        name = var.alias_domain_name
        zone_id = var.alias_zone_id
        evaluate_target_health = false
    }
}

