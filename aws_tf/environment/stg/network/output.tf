output "vpc_id" {
  value = module.network.vpc_id
}

output "subnet_ids" {
  value = module.network.subnet_ids
}

//output "route_table_web_id" {
//  value = module.network.route_table_web_id
//}

output "route_table_alb_id" {
  value = module.network.route_table_alb_id
}

output "db_security_group_id" {
  value = module.network.db_security_group_id
}

output "api_security_group_id" {
  value = module.network.api_security_group_id
}

output "alb_security_group_id" {
  value = module.network.alb_security_group_id
}

//output "web_security_group_id" {
//  value = module.network.web_security_group_id
//}
