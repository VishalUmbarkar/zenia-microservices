variable "rds_endpoint" {
  default = null
}
variable "ecs_sg_id" {
  
}
variable "private_subnets" {
  
}

variable "wordpress_tg_arn" {
  
}
variable "nodejs_tg_arn" {
  
}
variable "vpc_id" {
  
}
variable "ecs_services" {
  description = "List of ECS services to scale"
  type = list(object({
    name          = string
    cluster       = string
    min_capacity  = number
    max_capacity  = number
  }))
  default = [
    { name = "microservice-service", cluster = "ecs-cluster", min_capacity = 1, max_capacity = 3 },
    { name = "wordpress-service", cluster = "ecs-cluster", min_capacity = 1, max_capacity = 3 }
  ]
}

variable "db_name" {
  
}

variable "ecs_task_execution_role_arn" {
  
}

variable "ecs_task_role_arn" {
  
}
# variable "alb_target_group_wordpress_arn" {
  
# }

# variable "container_name" {
  
# }
# variable "container_port" {
  
# }
# # variable "security_groups" {
  
# # }
# variable "task_definition_arn" {
  
# }
# variable "desired_count" {
  
# }
# variable "service_name" {
  
# }
# variable "vpc_id" {
  
# }