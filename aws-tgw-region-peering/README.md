# Inter-region Transit Gateway peering 


>__If you're not using `aws cli` credentials for authentication, refer to [AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) for all available options.__

I used two AWS regions `us-west-1` and `us-east-1` for [TGW](https://aws.amazon.com/transit-gateway) inter-region peering. The use of Terraform [modules](https://www.terraform.io/docs/configuration/modules.html) is to avoid repetition. This particular example assumes that both regions already have TGWs stood up and ready to go. The three distinct environments of dev, stage and prod with their respective directories out of which you should run terrafrom to provision resources is just an attempt to demonstrate a typical scenario with such environments. Once provisioning is done, the use of `routes_to_usw1` and `routes_to_use1` route tables is meant to point static routes at each other since TGW currently does not support dynamic routing. Those static routes represent attached VPCs to the regional TGW.  
