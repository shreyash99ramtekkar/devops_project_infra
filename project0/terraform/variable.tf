variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"

}
variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "prod"
    Owner       = "Shreyash"
    Team        = "Platform"
    CostCenter  = "Ops"
  }
}


variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "devops-projects.tech"
}