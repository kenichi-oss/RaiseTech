output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}
output "ec2_instance_type" {
  value = module.ec2.instance_type
}
output "storage_type" {
  value = module.rds.storage_type
}
output "engine" {
  value = module.rds.engine
} 

