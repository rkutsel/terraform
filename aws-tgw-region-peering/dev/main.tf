terraform {
  backend "s3" {
    profile        = "tgw-use1"
    session_name   = "terraform"
    dynamodb_table = "terraform-tgw-dev"
    bucket         = "terraform-tgw-dev"
    key            = "vpc_name_dev/terraform.tfstate"
    region         = "us-east-1"
  }
}

locals {
  usw1 = "us-west-1"
  use1 = "us-east-1"
  tgw_profile = "tgw_profile_name"
}

module "tgw-peering" {
  source = "../."

  providers = {
    aws.tgw-usw1 = aws.tgw-usw1
    aws.tgw-use1 = aws.tgw-use1
  }  
  tgw-name = "dev"

  routes_to_usw1 = [
   "172.16.0.0/16", #example use1 -> usw1 | dev
 ]

  routes_to_use1 = [
   "172.17.0.0/16", #example usw1 -> use1 | dev
 ]

}

provider "aws" {
  alias   = "tgw-usw1"
  profile = local.tgw_profile
  region  = local.usw1
}

provider "aws" {
  alias   = "tgw-use1"
  profile = local.tgw_profile
  region  = local.use1
}
