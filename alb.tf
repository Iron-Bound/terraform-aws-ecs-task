resource "aws_lb" "alb" {
  count = var.public_subnets != [] ? 1 : 0

  name               = replace("${local.stack}_${var.name}", "_", "")
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.alb_sg[0].id]
  internal           = false
  load_balancer_type = "application"
}

data "aws_subnet" "public_subnet" {
  count = var.public_subnets != [] ? 1 : 0

  id = var.public_subnets[0]
}

resource "aws_lb_target_group" "alb_target_group_blue" {
  count = var.public_subnets != [] ? 1 : 0

  name        = replace("${local.stack}_${var.name}_blue", "_", "")
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_subnet.public_subnet[0].vpc_id
  port        = var.container_port

  depends_on = [ "aws_lb.alb" ]
}

resource "aws_lb_target_group" "alb_target_group_green" {
  count = var.public_subnets != [] ? 1 : 0

  name        = replace("${local.stack}_${var.name}_green", "_", "")
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_subnet.public_subnet[0].vpc_id
  port        = var.container_port

  depends_on = [ "aws_lb.alb" ]
}

data "aws_acm_certificate" "app_cert" {
  count = var.cert_domain != "" ? 1 : 0

  domain = "${var.cert_domain}"
}

resource "aws_lb_listener" "alb_listener" {
  count = var.public_subnets != [] ? 1 : 0

  load_balancer_arn = "${aws_lb.alb[0].arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    target_group_arn = aws_lb_target_group.alb_target_group_blue[0].arn
    type             = "forward"
  }

  certificate_arn = data.aws_acm_certificate.app_cert[0].arn
}

resource "aws_security_group" "alb_sg" {
  count = var.public_subnets != [] ? 1 : 0

  name        = "${local.stack}-${var.name}-alb-sg"
  description = "Allow HTTP from Anywhere into ALB"
  vpc_id      = data.aws_subnet.public_subnet[0].vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = ["${aws_security_group.app_sg[0].id}"]
  }

  tags = {
    Name = "${local.stack}-${var.name}-alb-sg"
  }
}

//allow inbound traffic only from load balancer
resource "aws_security_group" "app_sg" {
  count = var.public_subnets != [] ? 1 : 0

  name        = "${local.stack}-${var.name}-app-sg"
  description = "Allow HTTP from from LB into instances"
  vpc_id      = data.aws_subnet.public_subnet[0].vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.stack}-${var.name}-app-sg"
  }
}

resource "aws_security_group_rule" "alb_sg_rule" {
  count = var.public_subnets != [] ? 1 : 0

  security_group_id = aws_security_group.app_sg[0].id
  type = "ingress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  source_security_group_id = aws_security_group.alb_sg[0].id
}

resource "aws_security_group_rule" "app_sg_rule" {
  count = var.public_subnets != [] ? 1 : 0

  security_group_id = aws_security_group.app_sg[0].id
  type = "ingress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  source_security_group_id = aws_security_group.app_sg[0].id
}
