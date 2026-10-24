output "db_endpoint" {
  value = aws_db_instance.main.address
}
output "storage_type" {
  value = aws_db_instance.main.storage_type
}
output "engine" {
  value = aws_db_instance.main.engine
}
