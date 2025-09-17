#Set terraform provider
terraform {

  cloud {
    # The name of your Terraform Cloud organization.
    organization = "sk-aws-resume-challenge"

    # The name of the Terraform Cloud workspace to store Terraform state files in.
    workspaces {
      name = "tf-resume-workspace"
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  region = var.region_name
}

#Manually register domain but show documnetation to register via:

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53domains_domain
