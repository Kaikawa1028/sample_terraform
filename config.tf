data "aws_caller_identity" "current" {}

data "aws_ami" "ecs_optimized_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["*ecs-optimized*"]
  }
  name_regex = "^amzn-ami-.*-amazon-ecs-optimized$"
  owners     = ["amazon"]
}

data "terraform_remote_state" "dev" {
  backend = "s3"
  config = {
    bucket = "sample-project.terraform"
    key    = "development.terraform.tfstate"
    region = "ap-northeast-1"
    }
}

terraform {
  required_version = "0.12.19"
  backend "s3" {
    bucket = "sample-project.terraform"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  version = "2.45.0"
  region  = var.region
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}
