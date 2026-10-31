variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "instance_id" {
  type = string
}

variable "additional_instance_ids" {
  type    = map(string)
  default = {}
}