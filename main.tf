locals {
  image      = var.image_tag == "latest" ? var.image : "${var.image}:${var.image_tag}"
  stack      = var.stack != "" ? var.stack : var.environment
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "${local.stack}_${var.name}"
  network_mode          = "awsvpc"
  execution_role_arn    = "arn:aws:iam::${var.aws_account_id}:role/ecsTaskExecutionRole"
  container_definitions = <<JSON
[
  {
    "cpu": 512,
    "essential": true,
    "memory": 1024,
    "memoryReservation": 512,
    "name": ""${local.stack}_${var.name}",
    "image": "${local.image}",
    "portMappings": [
      {
          "containerPort": 3000
      }
    ]
  }
]
JSON
}