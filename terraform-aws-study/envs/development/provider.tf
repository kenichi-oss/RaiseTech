provider "aws" {
  region  = var.region
  profile = "study"

  default_tags {
    tags = {
      Project     = "aws-study"
      Environment = var.env
      ManagedBy   = "terraform"
    }
  }
}
