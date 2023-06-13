terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
      configuration_aliases = [ aws.a, aws.b ]
    }
  }
}

#### AWS region and AWS key pair for region A
#### Cluster A will live in region A and use this provider
provider "aws" {
  alias      = "a"
  region     = var.region1
  access_key = var.aws_creds[0]
  secret_key = var.aws_creds[1]
}

#### AWS region and AWS key pair for region B
#### Cluster B will live in region B and use this provider
provider "aws" {
  alias      = "b"
  region     = var.region2
  access_key = var.aws_creds[0]
  secret_key = var.aws_creds[1]
}