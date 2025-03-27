data "aws_secretsmanager_secret" "db_secret" {
  name = "wordpress-db-creds"
}

module "vpc" {
  source = "./modules/network-modules/vpc"
  vpc_name = "zenia-vpc"
  cidr_range = "10.0.0.0/16"
}

module "subnets" {
    source = "./modules/network-modules/subnet"
    vpc_id           = module.vpc.vpc_id
  subnet_configs   = [
    { name = "public-subnet-1",  cidr = "10.0.1.0/24", public = true },
    { name = "public-subnet-2",  cidr = "10.0.2.0/24", public = true },
    { name = "private-subnet-1", cidr = "10.0.3.0/24", public = false },
    { name = "private-subnet-2", cidr = "10.0.4.0/24", public = false },
  ]
}

module "igw" {
    source = "./modules/network-modules/internet_gateway"
    vpc_id = module.vpc.vpc_id
}
module "nat-gw" {
  source = "./modules/network-modules/nat_gateway"
  public_subnet_ids = module.subnets.public_subnet_ids
}
module "route-tables" {
    source = "./modules/network-modules/route_table"
    vpc_id = module.vpc.vpc_id
    gateway_id = module.igw.gateway_id
    nat_gateway_id = module.nat-gw.nat_gateway_id
    public_subnet_ids = module.subnets.public_subnet_ids
    private_subnet_ids = module.subnets.private_subnet_ids
}

module "alb_security_group" {
    source = "./modules/network-modules/security_group"
    vpc_id = module.vpc.vpc_id
    sg_name = "zenia-alb-sg"
}
module "ecs_security_group" {
  source = "./modules/network-modules/security_group"
  vpc_id = module.vpc.vpc_id
  sg_name = "zenia-ecs-sg"
  ingress_rules = [{from_port=0, to_port = 0, protocol = "-1", cidr_blocks = [], security_groups = [module.alb_security_group.sg_id] }]
  egress_rules = [{from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"]}]
}

module "alb" {
  source = "./modules/network-modules/loadbalancer"
  name = "zenia-alb"
  public_subnet_ids = module.subnets.public_subnet_ids
  vpc_id = module.vpc.vpc_id
  type = "application"
  alb_sg_id = module.alb_security_group.sg_id
}

module "rds" {
  source = "./modules/rds"
  vpc_id = module.vpc.vpc_id
  private_subnets = module.subnets.private_subnet_ids
}

module "iam" {
  source = "./modules/iam"
  secrets_arn = data.aws_secretsmanager_secret.db_secret.arn
  task_role_name = "ecs_task_role"
  execution_role_name = "ecs_execution_role"

}

module "ecs_microservice" {
  source = "./modules/ecs/service"
  vpc_id = module.vpc.vpc_id
  # rds_endpoint = module.rds.rds_endpoint
  ecs_sg_id = module.ecs_security_group.sg_id
  private_subnets = module.subnets.private_subnet_ids
  wordpress_tg_arn = module.alb.wordpress_tg_arn
  nodejs_tg_arn = module.alb.nodejs_tg_arn
  db_name = module.rds.db_name
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn = module.iam.ecs_task_role_arn
}

module "route53_records" {
  source = "./modules/route53"
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id = module.alb.alb_zone_id
}
