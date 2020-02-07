provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
  version = "~> 2.7"
}

locals {
  aws_ecs_service_role  = "${var.aws_resource_prefix}-ecs-service-role"
  aws_ecs_instance_role = "${var.aws_resource_prefix}-ecs-instance-role"
  aws_ecs_load_balancer = "${var.aws_resource_prefix}-ecs-load-balancer"
  aws_ecs_target_group  = "${var.aws_resource_prefix}-ecs-target-group"
  # The name of the task definition
  aws_ecs_task_definition_name = "${var.aws_resource_prefix}-svc-task-definition"
  # The name of the CloudFormation stack to be created for the VPC and related resources
  aws_vpc_stack_name = "${var.aws_resource_prefix}-vpc-stack"
  # The name of the CloudFormation stack to be created for the ECS service and related resources
  aws_ecs_service_stack_name = "${var.aws_resource_prefix}-svc-stack"
  # The name of the ECR repository to be created
  aws_ecr_repository_name = "${var.aws_resource_prefix}"
  # The name of the ECS cluster to be created
  aws_ecs_cluster_name = "${var.aws_resource_prefix}-cluster"
  # The name of the ECS service to be created
  aws_ecs_service_name = "${var.aws_resource_prefix}-service"
  # The name of the execution role to be created
  aws_ecs_execution_role_name = "${var.aws_resource_prefix}-ecs-execution-role"
}

resource "aws_iam_role" "ecs-service-role" {
  name                  = ${local.aws_ecs_service_role}
  path                  = "/"
  assume_role_policy    = "${data.aws_iam_policy_document.ecs-service-policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs-service-role-attachment" {
    role       = "${aws_iam_role.ecs-service-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecs-service-policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ecs.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "ecs-instance-role" {
    name                = "${local.aws_ecs_instance_role}"
    path                = "/"
    assume_role_policy  = "${data.aws_iam_policy_document.ecs-instance-policy.json}"
}

data "aws_iam_policy_document" "ecs-instance-policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
    role       = "${aws_iam_role.ecs-instance-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
    name = "ecs-instance-profile"
    path = "/"
    roles = ["${aws_iam_role.ecs-instance-role.id}"]
    provisioner "local-exec" {
      command = "sleep 10"
    }
}

resource "aws_alb" "ecs-load-balancer" {
  name            = "${local.aws_ecs_load_balancer}"
  security_groups = ["${aws_security_group.test_public_sg.id}"]
  subnets         = ["${aws_subnet.test_public_sn_01.id}"]

  tags {
    Name = "${local.aws_ecs-load-balancer}"
  }
}

resource "aws_alb_target_group" "ecs-target-group" {
    name                = "${local.aws_ecs_target_group}"
    port                = "80"
    protocol            = "HTTP"
    vpc_id              = "${aws_vpc.test_vpc.id}"

    health_check {
        healthy_threshold   = "5"
        unhealthy_threshold = "2"
        interval            = "30"
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = "5"
    }

    tags {
      Name = "${local.aws_ecs_target_group}"
    }
}

resource "aws_alb_listener" "alb-listener" {
    load_balancer_arn = "${aws_alb.ecs-load-balancer.arn}"
    port              = "80"
    protocol          = "HTTP"

    default_action {
        target_group_arn = "${aws_alb_target_group.ecs-target-group.arn}"
        type             = "forward"
    }
}