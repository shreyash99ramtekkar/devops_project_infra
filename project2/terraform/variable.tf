variable "app_name" {
  description = "Name of the Application"
  type        = string
  default     = "web-app"
}

variable "my_ip" {
  description = "My IP address"
  type        = string

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

variable "env" {
  description = "Environment name"
  type        = string
  default     = "prod"

}
variable "db_password" {
  description = "Environment name"
  type        = string

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