variable "name" {
  
}

variable "public_subnet_ids" {
type = list(string)
}
variable "vpc_id" {
  
}
variable "type" {
  
}
variable "alb_sg_id" {

}
variable "certificate_arn" {
  default = "arn:aws:acm:ap-south-1:148761667975:certificate/2662ce8e-3709-4dae-8ca1-1dc9b13c6948"
}