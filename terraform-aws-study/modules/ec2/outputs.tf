#output "instance_id" {
#  value = aws_instance.ec2.id
#}
output "instance_id" {
  value = aws_instance.main.id
}

output "app_log_group_name" {
  value = aws_cloudwatch_log_group.app.name
}

output "instance_type" {
  value = aws_instance.main.instance_type
}
    