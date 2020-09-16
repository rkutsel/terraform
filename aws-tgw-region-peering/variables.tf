
variable "tgw-name"  {
  type = string
}

variable "routes_to_usw1"  {
  type = list(string)
  default = []
}

variable "routes_to_use1"  {
  type = list(string)
  default = []
}

locals {

  usw1 = "us-west-1"
  use1 = "us-east-1"
  tgw_profile_prod = "tgw-usw1"
  tgw_profile_stage = "tgw-use1"

  tags = {
    Name        = "tgw-inter-region-transit"
    Environment = "internal"
    Owner       = "devops"
    Service     = "transit"
  }
}
