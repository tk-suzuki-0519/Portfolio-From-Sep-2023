provider "aws" {
  region = var.main_region
}
provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}