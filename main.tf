#Set terraform providers
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  region = var.region_name
}

#To do: Update policy for S3 bucket after CF deployment


#Manually register domain but show documnetation to register via:
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53domains_domain