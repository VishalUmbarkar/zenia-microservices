output "rds_endpoint" {
  value = aws_db_instance.wordpress_db.endpoint
}
output "db_name" {
  value = aws_db_instance.wordpress_db.db_name
}