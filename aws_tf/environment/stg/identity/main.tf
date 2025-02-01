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
        key = "sprint4-identity/terraform.tfstate" // ここはフォルダによって変える
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

/////////////// resource ///////////////


module "identity" {
  source = "../../../my_modules/identity"
  pgp_key = var.pgp_key
}
