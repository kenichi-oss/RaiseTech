provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "aws-study"
      Environment = var.env
      ManagedBy   = "terraform"
    }
  }
}
