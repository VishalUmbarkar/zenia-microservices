variable "vpc_id" {}
variable "subnet_configs" {
  type = list(object({
    name  = string
    cidr  = string
    public = bool
  }))
}
