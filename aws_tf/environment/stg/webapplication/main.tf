terraform {
  required_version = "1.9.8" // Terraformのバージョン要件
  required_providers {
    aws = {
      source  = "hashicorp/aws" // AWSプロバイダーを使用
      version = "5.79.0"        // AWSプロバイダーのバージョン要件
    }
  }
  backend "s3" {
        bucket = "sprint4-tfstate-stg-8782"
        key = "sprint4-webapplication/terraform.tfstate" // ここはフォルダによって変える
        region = "ap-northeast-1"
        dynamodb_table = "sprint4-tfstate-lock-stg-8782"
        encrypt = true
    }
}

provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      Project = "sprint4"
      category = "main"
      Environment = "stg"
    }
  }
}

provider "aws" {
  alias = "acm-region"
  region = "ap-northeast-1"
}


data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "sprint4-tfstate-stg-8782"
    key = "sprint4-network/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "database" {
  backend = "s3"
  config = {
    bucket = "sprint4-tfstate-stg-8782"
    key = "sprint4-database/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "identity" {
  backend = "s3"
  config = {
    bucket = "sprint4-tfstate-stg-8782"
    key = "sprint4-identity/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "general" {
  backend = "s3"
  config = {
    bucket = "sprint4-tfstate-stg-8782"
    key = "sprint4-general/terraform.tfstate"
    region = "ap-northeast-1"
  }
}


/////////////// resource ///////////////


module "tls_cert" {
  source = "../../../my_modules/tls_cert"
  providers = {
    aws.acm-region = aws.acm-region
  }
  domain_name = "api.${data.terraform_remote_state.general.outputs.route53_zone_name}"  
  route53_zone_id = data.terraform_remote_state.general.outputs.route53_zone_id
}

module "dns_zone" {
  source = "../../../my_modules/dns"
  domain_name = "api.${data.terraform_remote_state.general.outputs.route53_zone_name}"  
  route53_zone_id = data.terraform_remote_state.general.outputs.route53_zone_id
  alias_domain_name = module.compute.api_alb_endpoint
  alias_zone_id = module.compute.api_alb_zone_id
}


module "compute" {
  source             = "../../../my_modules/compute"
  availability_zones = var.availability_zones
  db_address         = data.terraform_remote_state.database.outputs.db_address
  
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  db_port            = var.db_port
  instance_type      = var.instance_type
  key_name           = var.key_name
  vpc_id             = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids         = data.terraform_remote_state.network.outputs.subnet_ids
  //web_security_group_id = data.terraform_remote_state.network.outputs.web_security_group_id
  api_security_group_id = data.terraform_remote_state.network.outputs.api_security_group_id
  alb_security_group_id = data.terraform_remote_state.network.outputs.alb_security_group_id
  tls_cert_arn = module.tls_cert.acm_certificate_arn
}

