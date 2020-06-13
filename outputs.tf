output "listener_arn" {
    value=aws_lb_listener.alb_listener[0].arn
}

output "blue_target_group_arn" {
    value=aws_lb_target_group.alb_target_group_blue[0].name
}

output "green_target_group_arn" {
    value=aws_lb_target_group.alb_target_group_green[0].name
}

output "app_sg_id" {
    value=aws_security_group.app_sg[0].id
}
