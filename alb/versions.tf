terraform {
  required_version = ">= 0.1.3"

  required_providers {
    aws = {
      source : "hashicorp/aws",
      version : "~> 6.0"
    }
  }
}