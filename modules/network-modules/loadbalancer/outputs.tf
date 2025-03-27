output "wordpress_tg_arn"{
    value = aws_lb_target_group.wordpress.arn
}
output "nodejs_tg_arn" {
  value = aws_lb_target_group.micrservice.arn
}
output "alb_dns_name" {
  value = aws_lb.api_alb.dns_name
}
output "alb_zone_id" {
  value = aws_lb.api_alb.zone_id
}
