#### Provider variables
variable "region" {
    description = "AWS region"
}


variable "aws_creds" {
    description = "Access key and Secret key for AWS [Access Keys, Secret Key]"
}

variable "owner" {
    description = "owner tag name"
}

#### VPC
variable "base_name" {
    description = "base name for resources (prefix name)"
    default = "redisuser1-tf"
}

variable "vpc_cidr" {
    description = "vpc-cidr"
    default = "10.0.0.0/16"
}

#### Declare the list of subnet CIDR blocks
variable "subnet_cidr_blocks" {
    type = list(string)
    description = "subnet_cidr_block"
    default = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
}


#### Declare the list of availability zones
variable "subnet_azs" {
  type = list(string)
  default = ["us-west-2a","us-west-2b","us-west-2c"]
}
