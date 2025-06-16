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

# Make sure you change the value in the application.properties in ansible directory accordingly
variable "internal_hostname" {
  description = "Internal hostname for the load balancer"
  type        = string
  default     = "devops-projects-internal.tech"

}

variable "cert_arn" {
  description = "Certificate ARN for the load balancer"
  type        = string
}

