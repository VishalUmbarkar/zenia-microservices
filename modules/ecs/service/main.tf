# data "aws_iam_role" "execution_role" {
#   name = "deployer"
# }

data "aws_secretsmanager_secret" "db_secret" {
  name = "wordpress-db-creds"
}

resource "aws_ecs_cluster" "main" {
  name = "ecs-cluster"
}

# WordPress Task Definition
resource "aws_ecs_task_definition" "wordpress" {
  
  family                   = "wordpress-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn


  container_definitions = jsonencode([
    {
      name      = "wordpress"
      image     = "148761667975.dkr.ecr.ap-south-1.amazonaws.com/zenia:wordpress"
      memory    = 512
      cpu       = 256
      essential = true
      environment = [
        { name  = "WORDPRESS_DB_HOST", value = var.rds_endpoint},
        { name = "WORDPRESS_DB_NAME", value = var.db_name } 
      ]
       secrets = [
  { name = "WORDPRESS_DB_USER", valueFrom = "${data.aws_secretsmanager_secret.db_secret.id}:username::" },
  { name = "WORDPRESS_DB_PASSWORD", valueFrom = "${data.aws_secretsmanager_secret.db_secret.id}:password::" }
]
      portMappings = [
        { containerPort = 80, hostPort = 80 }
      ]
    }
  ])
  
}

# Microservice Task Definition
resource "aws_ecs_task_definition" "microservice" {
  family                   = "microservice-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "microservice"
      image     = "148761667975.dkr.ecr.ap-south-1.amazonaws.com/zenia:nodeapp"
      memory    = 256
      cpu       = 128
      essential = true
      portMappings = [
        { containerPort = 3000, hostPort = 3000 }
      ]
    }
  ])
}

# WordPress Service
resource "aws_ecs_service" "wordpress" {
  
  name            = "wordpress-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.wordpress.arn
  launch_type     = "FARGATE"
  desired_count = 1
  enable_execute_command = true

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [var.ecs_sg_id]
  }

  load_balancer {
    target_group_arn = var.wordpress_tg_arn
    container_name   = "wordpress"
    container_port   = 80
  }
}

# Microservice Service
resource "aws_ecs_service" "microservice" {
  name            = "microservice-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.microservice.arn
  launch_type     = "FARGATE"
  desired_count = 1

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [var.ecs_sg_id]
  }

  load_balancer {
    target_group_arn = var.nodejs_tg_arn
    container_name   = "microservice"
    container_port   = 3000
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  for_each           = { for service in var.ecs_services : service.name => service }
  max_capacity       = each.value.max_capacity
  min_capacity       = each.value.min_capacity
  resource_id        = "service/${each.value.cluster}/${each.value.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  depends_on = [aws_ecs_service.microservice, aws_ecs_service.wordpress]
}

resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  for_each           = aws_appautoscaling_target.ecs_target
  name               = "${each.key}-cpu-scaling"
  service_namespace  = "ecs"
  resource_id        = each.value.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value       = 75.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "ecs_memory_policy" {
  for_each           = aws_appautoscaling_target.ecs_target
  name               = "${each.key}-memory-scaling"
  service_namespace  = "ecs"
  resource_id        = each.value.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value       = 75.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}


