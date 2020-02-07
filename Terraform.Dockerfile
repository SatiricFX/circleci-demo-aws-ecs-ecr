FROM hashicorp/terraform

RUN git clone --single-branch --branch develop https://github.com/SatiricFX/circleci-demo-aws-ecs-ecr.git

WORKDIR /circleci-demo-aws-ecs-ecr/terraform_setup

