    variable "subnet_id" {
    description = "Subnet ID for the EC2 instance"
    type        = string
    }
    
    variable "project_name" {
    type = string
    }
    
    variable "key_name" {
    type = string
    }

    variable "ec2_sg_id" {
    type = string
    }

    variable "instance_profile_name" {
    type = string
    }

    variable "app_repo_url" {
    type = string
    }

    variable "db_endpoint" {
    type = string
    }

    variable "db_name" {
    type = string
    }

    variable "db_username" {
    type = string
    }

    variable "db_password" {
    type      = string
    sensitive = true
    }

    variable "instance_type" {
    description = "EC2 instance type"
    type        = string
    }