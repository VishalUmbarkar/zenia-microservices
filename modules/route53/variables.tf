variable "zone_id" {
  description = "The Route 53 Hosted Zone ID for vishalumbarkar.click"
  type        = string
  default = "Z0355766DTBOHT9TXV6J"
}

variable "alb_dns_name" {
  description = "The DNS name of the ALB"
  type        = string
}

variable "alb_zone_id" {
  description = "The Zone ID of the ALB"
  type        = string
}
