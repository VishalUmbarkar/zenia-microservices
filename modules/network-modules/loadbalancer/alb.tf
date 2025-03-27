resource "aws_lb_target_group" "micrservice" {
  name        = "micrservice-tg"
  port        = 80                      # Make sure this matches your microservice's actual running port
  target_type = "ip"
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    protocol            = "HTTP"
    port                = 3000             # Health check should match the target port
    path                = "/hello"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "wordpress" {
  name        = "wordpress-tg"
  port        = 80                         # WordPress runs on port 80
  target_type = "ip"
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    protocol            = "HTTP"
    path                = "/wp-json/wp/v2/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-302" 
  }
}

resource "aws_lb" "api_alb" {
  name               = var.name
  internal           = false
  load_balancer_type = var.type
  subnets            = var.public_subnet_ids
  security_groups    = [var.alb_sg_id]
}

# Single HTTP listener with host-based routing
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.api_alb.arn
  protocol          = "HTTP"
  port             = 80

   default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"  # Permanent Redirect
    }
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.api_alb.arn
  protocol = "HTTPS"
  port = 443
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.certificate_arn
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Invalid Host"
      status_code  = "404"
    }
  }
}

# Host-based routing for Microservice
resource "aws_lb_listener_rule" "micrservice_rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 1

  condition {
    host_header {
      values = ["microservice.vishalumbarkar.click"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.micrservice.arn
  }
}

# Host-based routing for WordPress
resource "aws_lb_listener_rule" "wordpress_rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 2

  condition {
    host_header {
      values = ["wordpress.vishalumbarkar.click"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress.arn
  }
}


# resource "aws_lb_target_group" "micrservice" {
#   port = 80
#   target_type = "ip"
#   protocol = "HTTP"
#   vpc_id = var.vpc_id
#   health_check {
#     protocol = "HTTP"
#     port = 3000
#     path = "/hello"
#     interval            = 30                # Health check interval (seconds)
#     timeout             = 5                 # Health check timeout (seconds)
#     healthy_threshold   = 3                 # Required healthy checks before target is considered healthy
#     unhealthy_threshold = 3 
#   }
# }
# resource "aws_lb_target_group" "wordpress" {
#   port = 80
#   target_type = "ip"
#   protocol = "HTTP"
#   vpc_id = var.vpc_id
#   health_check {
#     protocol = "HTTP"
#     path = "/wp-json/wp/v2/"
#     interval            = 30                # Health check interval (seconds)
#     timeout             = 5                 # Health check timeout (seconds)
#     healthy_threshold   = 3                 # Required healthy checks before target is considered healthy
#     unhealthy_threshold = 3 
#   }
# }

# resource "aws_lb" "api_alb" {
  
#   name               = var.name
#   internal           = false
#   load_balancer_type = var.type
#   subnets            = var.public_subnet_ids
#   security_groups = [var.alb_sg_id]
# }



# resource "aws_lb_listener" "micrservice_listener" {
#   load_balancer_arn = aws_lb.api_alb.arn
#   protocol = "HTTP"
#   port = 80
#   default_action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.micrservice.arn
#   }
  
# }
# resource "aws_lb_listener" "wordpress_listener" {
#   load_balancer_arn = aws_lb.api_alb.arn
#   protocol = "HTTP"
#   port = 80
#   default_action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.wordpress.arn
#   }
  
# }

