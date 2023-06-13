#### must have tf provider included in the module folder to 
#### utilize with multiple providers (ie different regions)

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
   } 
  }
}