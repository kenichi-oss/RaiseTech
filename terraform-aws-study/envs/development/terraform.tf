terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "tfstate-study-011528301388"
    key          = "development/terraform.tfstate"
    region       = "ap-northeast-1"
    profile      = "study"
    use_lockfile = true
    encrypt      = true
  }
}
