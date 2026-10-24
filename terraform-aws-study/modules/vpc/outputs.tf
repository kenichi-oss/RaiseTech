output "vpc_id" {
  value = aws_vpc.main.id
}
# VPCのサブネットの中にEC2を配置するため、サブネットのIDを出力する
# SG,RDS,EC2などがサブネットなどを参照できるように出力を追加。
output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
