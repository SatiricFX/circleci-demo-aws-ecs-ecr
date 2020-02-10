resource "aws_launch_configuration" "cwvlug-ecs-launch-configuration" {
    name                        = "cwvlug-ecs-launch-configuration"
    image_id                    = "ami-0f81924348bcd01a1"
    instance_type               = "t2.micro"
    iam_instance_profile        = "${aws_iam_instance_profile.cwvlug-ecs-instance-profile.id}"

    root_block_device {
      volume_type = "standard"
      volume_size = 30
      delete_on_termination = true
    }

    lifecycle {
      create_before_destroy = true
    }

    security_groups             = ["${aws_security_group.cwvlug_public_sg.id}"]
    associate_public_ip_address = "true"
    user_data                   = <<EOF
                                  #!/bin/bash
                                  echo ECS_CLUSTER=cwvlug_ecs_cluster} >> /etc/ecs/ecs.config
                                  EOF
}

resource "aws_autoscaling_group" "cwvlug-ecs-autoscaling-group" {
    name                        = "cwvlug-ecs-autoscaling-group"
    max_size                    = "1"
    min_size                    = "0"
    desired_capacity            = "1"
    vpc_zone_identifier         = ["${aws_subnet.cwvlug_public_sn_01.id}", "${aws_subnet.cwvlug_public_sn_00.id}"]
    launch_configuration        = "${aws_launch_configuration.cwvlug-ecs-launch-configuration.name}"
    health_check_type           = "ELB"
  }