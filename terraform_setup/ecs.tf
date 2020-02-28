data "aws_ecs_task_definition" "ecs_task_definition" {
  task_definition = "${aws_ecs_task_definition.ecs_task_definition.family}"
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family        = "cwvlug_circleci_demo"
  container_definitions = <<DEFINITION
[
  {
    "name": "cwvlug_circleci_demo",
    "image": "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/cwvlug-circleci-demo:latest",
    "essential": true,
    "memory": 256,
    "cpu": 1,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "ecs-service" {
  name            = "ecs-service"
  task_definition = "aws_ecs_task_definition.ecs_task_definition.arn"
  desired_count   = 1
  launch_type     = "EC2"
}
