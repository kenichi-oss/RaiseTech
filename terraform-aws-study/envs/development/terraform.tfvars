#
project_name = "my-app"
region       = "ap-northeast-1"

#VPC
env                  = "development"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

#EC2
#instance_type = "t3.micro"



