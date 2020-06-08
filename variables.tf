variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "region" {
  type        = string
  description = "AWS Region, e.g. us-east-1"
}

variable "name" {
  type        = string
  description = "Name of the task to define for ECS"
}

variable "image" {
  type        = string
  description = "Name of image to run in ECS task"
}

variable "environment" {
  type        = string
  description = "Infrastructure environment, e.g. staging or production"
  default     = "staging"
}

variable "stack" {
  type        = string
  description = "Name to differentiate applications deployed in the same infrastructure environment"
  default     = ""
}

variable "image_tag" {
  type        = string
  description = "Image tag to run in ECS task"
  default     = "latest"
}

variable "task_role_arn" {
  type        = string
  description = "IAM role to run ECS task with"
  default     = ""
}

variable "ecs_cluster_name" {
  type        = string
  description = "Elastic Container Service cluster name to deploy services to"
  default     = ""
}

variable "subnets" {
  type        = list(string)
  description = "VPC subnets to run ECS task in"
  default     = []
}

variable "security_groups" {
  type        = list(string)
  description = "VPC security groups to run ECS task in"
  default     = []
}