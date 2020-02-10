resource "aws_alb" "cwvlug-ecs-load-balancer" {
    name                = "${var.aws_resource_prefix}-ecs-load-balancer"
    security_groups     = ["${aws_security_group."cwvlug_public_sg.id}"]
    subnets             = ["${aws_subnet.cwvlug_public_sn_01.id}", "${aws_subnet.cwvlug_public_sn_02.id}"]

    tags {
      Name = "${var.aws_resource_prefix}-ecs-load-balancer"
    }
}

resource "aws_alb_target_group" "cwvlug-ecs-target-group" {
    name                = "$aws_resource_prefix_}-ecs-target-group"
    port                = "80"
    protocol            = "HTTP"
    vpc_id              = "${aws_vpc.${aws_resource_prefix}_vpc.id}"

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
      Name = "${var.aws_resource_prefix}ecs-target-group"
    }
}

resource "aws_alb_listener" "cwvlug-alb-listener" {
    load_balancer_arn = "${aws_alb.${var.aws_resource_prefix}-ecs-load-balancer.arn}"
    port              = "80"
    protocol          = "HTTP"

    default_action {
        target_group_arn = "${aws_alb_target_group.${var.aws_resource_pefix}-ecs-target-group.arn}"
        type             = "forward"
    }
}