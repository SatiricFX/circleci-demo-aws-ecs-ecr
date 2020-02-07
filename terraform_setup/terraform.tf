provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
  version = "~> 2.7"
}

terraform {
  backend "s3" {
    bucket = "cwvlug-circleci-demo-tf-state"
    key    = "key"
    region = "us-east-1"
  }
}

locals {
  aws_ecs_service_role      = "${var.aws_resource_prefix}-ecs-service-role"
  aws_ecs_instance_role     = "${var.aws_resource_prefix}-ecs-instance-role"
  aws_public_security_group = "${var.aws_resource_prefix}-public-security-group"


resource "aws_vpc" "cwvlug_circleci_vpc" {
  cidr_block = "${var.aws_vpc_cidr_block}"

  tags = {
    Name ="CWVLug_CircleCI_VPC"
  }
}

resource "aws_internet_gateway" "cwvlug_circleci_ig" {
  vpc_id = "${aws_vpc.cwvlug_circleci_vpc.id}"

  tags = {
    Name = "CWVLug_CircleCI_IG"
  }
}

resource "aws_subnet" "public_sn_01" {
  vpc_id      = "${aws_vpc.cwvlug_circleci_vpc.id}"
  cidr_block  = "${var.aws_vpc_public_sn_cidr_block}"
  
  tags = {
    Name = "CWVLug_CircleCI_Public_SN"
  }
}

resource "aws_route_table" "public_sn_rt_01" {
  vpc_id = "${aws_vpc.cwvlug_circleci_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.cwvlug_circleci_ig.id}"
  }
  
  tags = {
    Name = "CWVLug_CircleCI_Public_SN_RT"
  }
}

# Associate the routing table to public subnet 1
resource "aws_route_table_association" "public_sn_rt_01_assn" {
  subnet_id = "${aws_subnet.public_sn_01.id}"
  route_table_id = "${aws_route_table.public_sn_rt_01.id}"
}

resource "aws_security_group" "public_sg" {
  name = "${local.aws_public_security_group}"
  description = "Public access security group"
  vpc_id = "${aws_vpc.cwvlug_circleci_vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = [
      "${var.aws_vpc_public_sn_cidr_block}"]
  }

  egress {
    # allow all traffic to private SN
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "public_sg"
  }
}

resource "aws_iam_role" "ecs-service-role" {
  name                  = "${local.aws_ecs_service_role}"
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
  name            = "ecs-load-balancer"
  security_groups = ["${aws_security_group.public_sg.id}"]
  subnets         = ["${aws_subnet.public_sn_01.id}"]

  tags = {
    Name = "ecs_load_balancer"
  }
}

resource "aws_alb_target_group" "ecs-target-group" {
    name                = "ecs-target-group"
    port                = "80"
    protocol            = "HTTP"
    vpc_id              = "${aws_vpc.cwvlug_circleci_vpc.id}"

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

    tags = {
      Name = "ecs_target_group"
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

resource "aws_launch_configuration" "ecs-launch-configuration" {
    name                        = "ecs-launch-configuration"
    image_id                    = "ami-0f81924348bcd01a1"
    instance_type               = "t2.micro"
    iam_instance_profile        = "${aws_iam_instance_profile.ecs-instance-profile.id}"

    root_block_device {
      volume_type = "standard"
      volume_size = 30
      delete_on_termination = true
    }

    lifecycle {
      create_before_destroy = true
    }

    security_groups             = ["${aws_security_group.public_sg.id}"]
    associate_public_ip_address = "true"
    user_data                   = <<EOF
                                  #!/bin/bash
                                  echo ECS_CLUSTER=${var.ecs_cluster} >> /etc/ecs/ecs.config
                                  EOF
}