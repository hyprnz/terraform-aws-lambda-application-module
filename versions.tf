terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source : "hashicorp/aws",
      version : ">= 5.32.0, <6.0.0"
    }
  }
}