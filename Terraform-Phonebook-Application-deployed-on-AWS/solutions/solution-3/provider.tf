terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.1.0"
    }
     github = {
      source = "integrations/github"
      version = "5.26.0"
    }   
  }
}

provider "aws" {
    region = "us-east-1"
  # Configuration options
}

provider "github" {
    token = "xxxxxxxxxxxxxxxxxxxxxxxxxxx"
  # Configuration options
}