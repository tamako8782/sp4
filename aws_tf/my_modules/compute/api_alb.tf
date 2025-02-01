//有償になるので一旦使わん
//resource "aws_eip" "api_eip1a" {
//  domain = "vpc"
//  tags = {
//    Name = "api-eip1a"
//  }
//}
//
//resource "aws_eip" "api_eip1c" {
//  domain = "vpc"
//  tags = {
//    Name = "api-eip1c"
//  }
//}
//
locals {
  alb_subnet_ids = [for name,id in var.subnet_ids : id if contains(["alb-subnet-01", "alb-subnet-02"], name)]
}

resource "aws_lb" "api_alb" {
  name = "api-alb"
  internal = false
  load_balancer_type = "application"
  subnets = local.alb_subnet_ids
  enable_deletion_protection = false
  security_groups = [var.alb_security_group_id]
//有償になるので一旦使わん
//  subnet_mapping {
//    subnet_id = local.api_subnet_ids[0]
//    allocation_id = aws_eip.api_eip.id
//  }
//
//  subnet_mapping {
//    subnet_id = local.api_subnet_ids[1]
//    allocation_id = aws_eip.api_eip1c.id
//  }
//

  tags = {
    Name = "api-alb"
  }
}



resource "aws_lb_target_group" "api_alb_target_group" {
  name_prefix = "apialb"
  port = 8080
  protocol = "HTTP"
  vpc_id = var.vpc_id
  deregistration_delay = 300
  health_check {
    port = 8080
    protocol = "HTTP"
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 5
    interval = 30
  }

  lifecycle {
    create_before_destroy = true
  }
  
}



resource "aws_lb_listener" "api_alb_listener" {
  load_balancer_arn = aws_lb.api_alb.arn
  port = "8080"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
  certificate_arn = var.tls_cert_arn
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.api_alb_target_group.arn
  }
}

////////////////////// output //////////////////////

output "api_alb_arn" {
  value = aws_lb.api_alb.arn
}

output "api_alb_endpoint" {
  value = aws_lb.api_alb.dns_name
}

output "api_alb_zone_id" {
  value = aws_lb.api_alb.zone_id
}
