resource "aws_ecs_cluster" "cwvlug-ecs-cluster" {
    name = "cwvlug_ecs_cluster"
}

data "aws_ecs_task_definition" "cwvlug_ecs_task_definition" {
  task_definition = "${aws_ecs_task_definition.cwvlug_ecs_task_definition.family}"
}

resource "aws_ecs_task_definition" "cwvlug_ecs_task_definition" {
    family                = "cwvlug_task_definition"
    container_definitions = <<DEFINITION
[
  {
    "name": "cwvlug_circleci_demo",
    "image": "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/cwvlug-circleci-demo:latest",
    "essential": true,
    "memory": 500,
    "cpu": 10,
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

resource "aws_ecs_service" "cwvlug-ecs-service" {
  	name            = "cwvlug-ecs-service"
  	iam_role        = "${aws_iam_role.cwvlug-ecs-service-role.name}"
  	cluster         = "${aws_ecs_cluster.cwvlug-ecs-cluster.id}"
    task_definition = "${aws_ecs_task_definition.cwvlug_ecs_task_definition.arn}"
  	desired_count   = 2

  	load_balancer {
    	target_group_arn  = "${aws_alb_target_group.cwvlug-ecs-target-group.arn}"
    	container_port    = 80
    	container_name    = "cwvlug"
	}
}