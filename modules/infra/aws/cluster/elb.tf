resource "aws_acm_certificate" "cert" {
  private_key       = tls_private_key.controller_private_key.private_key_pem
  certificate_body  = tls_locally_signed_cert.controller_signed_cert.cert_pem
  certificate_chain = tls_self_signed_cert.ca_cert.cert_pem
}

resource "aws_lb" "controller_lb" {
  name                             = "controller-lb"
  internal                         = false
  load_balancer_type               = "application"
  enable_cross_zone_load_balancing = false
  subnets                          = module.vpc.public_subnets
  security_groups                  = [module.web_sg.security_group_id]
  tags = {
    Name = "controller-lb"
  }
}

resource "aws_lb" "controller_internal_lb" {
  name                             = "controller-internal-lb"
  internal                         = true
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = false
  subnets                          = module.vpc.private_subnets
  /* security_groups                  = [module.web_internal_sg.security_group_id] */
  tags = {
    Name = "controller-internal-lb"
  }
}

resource "aws_lb_listener" "controller_lb_listener" {
  load_balancer_arn = aws_lb.controller_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.controller_lb_tg.arn
  }
}

resource "aws_lb_listener" "controller_internal_lb_listener" {
  load_balancer_arn = aws_lb.controller_internal_lb.arn
  port              = "9201"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.controller_internal_lb_tg.arn
  }
}

resource "aws_lb_target_group" "controller_lb_tg" {
  name        = "${var.deployment_id}-lb-tg"
  port        = 9200
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path                = "/health"
    port                = 9203
    protocol            = "HTTPS"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 10
    timeout             = 2
  }
}

resource "aws_lb_target_group" "controller_internal_lb_tg" {
  name        = "${var.deployment_id}-int-lb-tg"
  port        = 9201
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path                = "/health"
    port                = 9203
    protocol            = "HTTPS"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 10
    timeout             = 2
  }
}

resource "aws_lb_target_group_attachment" "controller_lb_tg_attachment" {
  count            = var.controller_count
  target_group_arn = aws_lb_target_group.controller_lb_tg.arn
  target_id        = aws_instance.controller[count.index].id
  port             = 9200
}


resource "aws_lb_target_group_attachment" "controller_internal_lb_tg_attachment" {
  count            = var.controller_count
  target_group_arn = aws_lb_target_group.controller_internal_lb_tg.arn
  target_id        = aws_instance.controller[count.index].id
  port             = 9201
}

/*
resource "aws_lb" "controller_lb" {
  name                             = "controller-lb"
  internal                         = false
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  subnets                          = module.vpc.public_subnets

  tags = {
    Name = "controller-lb"
  }
}

resource "aws_lb_listener" "controller_lb_listener" {
  load_balancer_arn = aws_lb.controller_lb.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.controller_lb_tg.arn
  }
}

resource "aws_lb_listener" "controller_cluster_lb_listener" {
  load_balancer_arn = aws_lb.controller_lb.arn
  port              = "9201"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.controller_cluster_lb_tg.arn
  }
}

resource "aws_lb_target_group" "controller_lb_tg" {
  name        = "${var.deployment_id}-lb-tg"
  port        = 9200
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path                = "/health"
    port                = 9203
    protocol            = "HTTPS"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 10
    timeout             = 2
  }
}

resource "aws_lb_target_group" "controller_cluster_lb_tg" {
  name        = "${var.deployment_id}-clst-lb-tg"
  port        = 9201
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path                = "/health"
    port                = 9203
    protocol            = "HTTPS"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 10
    timeout             = 2
  }
}

resource "aws_lb_target_group_attachment" "controller_lb_tg_attachment" {
  count            = var.controller_count
  target_group_arn = aws_lb_target_group.controller_lb_tg.arn
  target_id        = aws_instance.controller[count.index].id
  port             = 9200
}


resource "aws_lb_target_group_attachment" "controller_cluster_lb_tg_attachment" {
  count            = var.controller_count
  target_group_arn = aws_lb_target_group.controller_cluster_lb_tg.arn
  target_id        = aws_instance.controller[count.index].id
  port             = 9201
}
*/
