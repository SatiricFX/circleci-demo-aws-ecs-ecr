resource "aws_iam_role" "cwvlug-ecs-service-role" {
    name                = "${var.aws_resource_prefix}-ecs-service-role"
    path                = "/"
    assume_role_policy  = "${data.aws_iam_policy_document.cwvlug-ecs-service-policy.json}"
}

resource "aws_iam_role_policy_attachment" "cwvlug-ecs-service-role-attachment" {
    role       = "${aws_iam_role.cwvlug-ecs-service-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "cwvlug-ecs-service-policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ecs.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "cwvlug-ecs-instance-role" {
    name                = "cwvlug-ecs-instance-role"
    path                = "/"
    assume_role_policy  = "${data.aws_iam_policy_document.cwvlug-ecs-instance-policy.json}"
}

data "aws_iam_policy_document" "cwvlug-ecs-instance-policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "cwvlug-ecs-instance-role-attachment" {
    role       = "${aws_iam_role.cwvlug-ecs-instance-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "cwvlug-ecs-instance-profile" {
    name = "cwvlug-ecs-instance-profile"
    path = "/"
    role = "${aws_iam_role.cwvlug-ecs-instance-role.id}"
    provisioner "local-exec" {
      command = "sleep 10"
    }
}
