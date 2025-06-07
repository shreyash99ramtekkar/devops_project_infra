variable "app_name" {
  description = "Name of the VPC"
  type        = string
  default     = "web-app"
}

variable "my_ip" {
  description = "My IP address"
  type        = string
  default     = "109.76.173.169/32"

}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"

}

variable "key_pair" {
  description = "Key pair name"
  type        = string
  default     = "new-key-pair"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "web-app"
    Environment = "prod"
    Owner       = "Shreyash"
    Team        = "Devops"
    CostCenter  = "Ops"
  }
}
