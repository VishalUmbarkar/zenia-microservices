resource "aws_route53_record" "api_record" {
  zone_id = var.zone_id
  name    = "microservice.vishalumbarkar.click"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "wordpress_record" {
  zone_id = var.zone_id
  name    = "wordpress.vishalumbarkar.click"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
