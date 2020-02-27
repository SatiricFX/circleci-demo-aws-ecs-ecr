resource "aws_key_pair" "cwvlug-key-pair" {
  key_name   = "cwvlug-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

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
    key_name                    = "cwvlug-key"
    user_data                   = <<EOF
                                  #!/bin/bash
                                  echo ECS_CLUSTER=cwvlug-ecs-cluster} >> /etc/ecs/ecs.config
                                  EOF
}

resource "aws_autoscaling_group" "cwvlug-ecs-autoscaling-group" {
    name                        = "cwvlug-ecs-autoscaling-group"
    max_size                    = "1"
    min_size                    = "0"
    desired_capacity            = "1"
    vpc_zone_identifier         = ["${aws_subnet.cwvlug_public_sn_01.id}", "${aws_subnet.cwvlug_public_sn_02.id}"]
    launch_configuration        = "${aws_launch_configuration.cwvlug-ecs-launch-configuration.name}"
    health_check_type           = "ELB"
  }