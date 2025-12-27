terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50.0" # Use the latest stable version or your preferred one
    }
  }
}

provider "aws" {
  region = "us-east-2" # Change to your preferred AWS region
}