module "vpc" {
  source   = "../../modules/vpc"
  env      = var.env
  vpc_cidr = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

module "security_group" {
  source = "../../modules/security_group"
  env    = var.env
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "iam" {
  source       = "../../modules/iam"
  project_name = var.project_name
}

module "rds" {
  source             = "../../modules/rds"
  project_name       = var.project_name
  private_subnet_ids = module.vpc.private_subnet_ids
  db_sg_id           = module.security_group.db_sg_id
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
}

module "ec2" {
  source                = "../../modules/ec2"
  project_name          = var.project_name
  key_name              = var.key_name
  subnet_id             = module.vpc.public_subnet_ids[0]
  ec2_sg_id             = module.security_group.ec2_sg_id
  instance_profile_name = module.iam.instance_profile_name
  app_repo_url          = var.app_repo_url
  db_endpoint           = module.rds.db_endpoint
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  instance_type         = var.instance_type
}

module "alb" {
  source            = "../../modules/alb"
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security_group.alb_sg_id
  instance_id       = module.ec2.instance_id
}

module "waf" {
  source       = "../../modules/waf"
  project_name = var.project_name
  alb_arn      = module.alb.alb_arn
}

module "monitoring" {
  source             = "../../modules/monitoring"
  project_name       = var.project_name
  notification_email = var.notification_email
  instance_id        = module.ec2.instance_id
  app_log_group_name = module.ec2.app_log_group_name
  web_acl_name       = module.waf.web_acl_name
}