terraform {
  required_version = ">= 0.12.31"

  required_providers {
    aws = {
      source : "hashicorp/aws",
      version : ">= 5.26.0, <6.0.0"
    }
  }
}