resource "aws_ecs_cluster" "cwvlug-ecs-cluster" {
    name = "cwvlug_ecs_cluster"
}

data "aws_ecs_task_definition" "cwvlug_task_definition" {
  task_definition = "${aws_ecs_task_definition.cwvlug_task_definition.family}"
}

resource "aws_ecs_task_definition" "cwvlug_task_definition" {
    family                = "cwvlug_task_definition"
    container_definitions = <<DEFINITION
[
  {
    "name": "cwvlug",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "memory": 256,
    "cpu": 1
  },
]
DEFINITION
}

resource "aws_ecs_service" "cwvlug-ecs-service" {
  	name            = "cwvlug-ecs-service"
  	iam_role        = "${aws_iam_role.cwvlug-ecs-service-role.name}"
  	cluster         = "${aws_ecs_cluster.cwvlug-ecs-cluster.id}"
  	task_definition = "${aws_ecs_task_definition.cwvlug_task_definition.family}:${max("${aws_ecs_task_definition.cwvlug_task_definition.revision}", "${data.aws_ecs_task_definition.cwvlug_task_definition.revision}")}"
  	desired_count   = 2

  	load_balancer {
    	target_group_arn  = "${aws_alb_target_group.cwvlug-ecs-target-group.arn}"
    	container_port    = 80
    	container_name    = "cwvlug"
	}
}