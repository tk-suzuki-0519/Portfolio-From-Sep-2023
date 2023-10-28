terraform {
  cloud {
    organization = "Portfolio-From-Sep-2023"
    workspaces {
      name = "terraform-envs-main_region"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
  required_version = ">= 1.6.0"
}