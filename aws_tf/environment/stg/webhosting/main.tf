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
        key = "sprint4-webhosting/terraform.tfstate" // ここはフォルダによって変える
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
  region = "us-east-1"
}



//data "terraform_remote_state" "network" {
//  backend = "s3"
//  config = {
//    bucket = "sprint4-tfstate-stg-8782"
//    key = "sprint4-network/terraform.tfstate"
//    region = "ap-northeast-1"
//  }
//}
//
//data "terraform_remote_state" "database" {
//  backend = "s3"
//  config = {
//    bucket = "sprint4-tfstate-stg-8782"
//    key = "sprint4-database/terraform.tfstate"
//    region = "ap-northeast-1"
//  }
//}
//
//data "terraform_remote_state" "identity" {
//  backend = "s3"
//  config = {
//    bucket = "sprint4-tfstate-stg-8782"
//    key = "sprint4-identity/terraform.tfstate"
//    region = "ap-northeast-1"
//  }
//}
//
data "terraform_remote_state" "general" {
  backend = "s3"
  config = {
    bucket = "sprint4-tfstate-stg-8782"
    key = "sprint4-general/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
//
//data "terraform_remote_state" "webapplication" {
//  backend = "s3"
//  config = {
//    bucket = "sprint4-tfstate-stg-8782"
//    key = "sprint4-webapplication/terraform.tfstate"
//    region = "ap-northeast-1"
//  }
//}

/////////////// resource ///////////////

module "static_content" {
  source = "../../../my_modules/static_content"
  static_bucket_name = var.static_bucket_name
  acm_certificate_arn = module.tls_cert.acm_certificate_arn
  route53_zone_name = data.terraform_remote_state.general.outputs.route53_zone_name
}

module "tls_cert" {
  source = "../../../my_modules/tls_cert"
  providers = {
    aws.acm-region = aws.acm-region
  }
  domain_name = data.terraform_remote_state.general.outputs.route53_zone_name
  route53_zone_id = data.terraform_remote_state.general.outputs.route53_zone_id
}

module "dns" {
  source = "../../../my_modules/dns"
  domain_name = data.terraform_remote_state.general.outputs.route53_zone_name
  route53_zone_id = data.terraform_remote_state.general.outputs.route53_zone_id
  alias_domain_name = module.static_content.cloudfront_distribution_domain_name
  alias_zone_id = module.static_content.cloudfront_distribution_zone_id
}

output "cloudfront_distribution_domain_name" {
  value = module.static_content.cloudfront_distribution_domain_name
}

