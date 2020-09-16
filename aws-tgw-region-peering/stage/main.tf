terraform {
  backend "s3" {
    profile        = "tgw-use1"
    session_name   = "terraform"
    dynamodb_table = "terraform-tgw-stage"
    bucket         = "terraform-tgw-stage"
    key            = "vpc_name_stage/terraform.tfstate"
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
  tgw-name = "stage"

  routes_to_usw1 = [
   "10.16.0.0/16", #example use1 -> usw1 | stage
 ]

  routes_to_use1 = [
   "10.17.0.0/16", #example usw1 -> use1 | stage
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
