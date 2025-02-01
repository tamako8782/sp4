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
        key = "sprint4-database/terraform.tfstate" // ここはフォルダによって変える
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

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "sprint4-tfstate-stg-8782"
    key = "sprint4-network/terraform.tfstate"
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


/////////////// resource ///////////////


module "database" {
  source = "../../../my_modules/database"
  db_identifier      = var.db_identifier
  db_name = var.db_name
  db_username = var.db_username
  db_password = var.db_password
  db_port = var.db_port
  multi_az = var.multi_az
  subnet_ids = data.terraform_remote_state.network.outputs.subnet_ids
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  db_security_group_id = data.terraform_remote_state.network.outputs.db_security_group_id

}

