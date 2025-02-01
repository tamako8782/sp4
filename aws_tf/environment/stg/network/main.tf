terraform {
  required_version = "1.9.8" // Terraformのバージョン要件
  required_providers {
    aws = {
      source  = "hashicorp/aws" // AWSプロバイダーを使用
      version = "5.79.0"        // AWSプロバイダーのバージョン要件
    }
  }
// バックエンドの設定(S3、DynamoDBが作成されたあとに作成されるべき)
  backend "s3" {
        bucket = "sprint4-tfstate-stg-8782"
        key = "sprint4-network/terraform.tfstate" // ここはフォルダによって変える
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
      category = "network"
      Environment = "stg"
    }
  }
}


/////////////// resource ///////////////

module "network" {
  source = "../../../my_modules/network"

  vpc_cidr_block = var.vpc_cidr_block
  subnet_params  = var.subnet_params
}

