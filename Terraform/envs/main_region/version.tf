terraform {
  cloud {
    organization = "Portfolio-From-Sep-2023"
    workspaces {
      name = "infra"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.23.0"
    }
  }
  required_version = ">= 1.6.0"
}