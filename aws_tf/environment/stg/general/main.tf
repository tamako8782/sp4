
terraform {
  required_version = "1.9.8" // Terraformのバージョン要件
  required_providers {
    aws = {
      source  = "hashicorp/aws" // AWSプロバイダーを使用
      version = "5.79.0"        // AWSプロバイダーのバージョン要件
    }
  }
// バックエンドの設定(S3、DynamoDBが作成されたあとに作成されるべき)
// まだ作成されてないときはコメントアウトすべし
  backend "s3" {
        bucket = "sprint4-tfstate-stg-8782"
        key = "sprint4-general/terraform.tfstate" // ここはフォルダによって変える
        region = "ap-northeast-1"
        dynamodb_table = "sprint4-tfstate-lock-stg-8782"
        encrypt = true
    }

}

provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      Project = "sprint"
      category = "general"
      Environment = "stg"
    }
  }
}






/////////////// resource ///////////////

module "tfstate_management" {
  source = "../../../my_modules/tfstate_management"
  // s3
  bucket_name = "sprint4-tfstate-stg-8782"

  // dynamodb
  dynamodb_table_name = "sprint4-tfstate-lock-stg-8782"
}


resource "aws_route53_zone" "sprint_zone" {
  name = "beacon8782.xyz"
}



/////////////// output ///////////////

output "tfstate_bucket_id" {
  value = module.tfstate_management.tf_state_bucket_id
}

output "tfstate_bucket_arn" {
  value = module.tfstate_management.tf_state_bucket_arn
}

output "dynamodb_table_id" {
  value = module.tfstate_management.dynamodb_table_id
}

output "route53_zone_id" {
  value = aws_route53_zone.sprint_zone.zone_id
}

output "route53_zone_name" {
  value = aws_route53_zone.sprint_zone.name
}

output "route53_zone_name_servers" {
  value = aws_route53_zone.sprint_zone.name_servers
}
