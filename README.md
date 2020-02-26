# CircleCI Demo: AWS ECS ECR [![CircleCI status](https://circleci.com/gh/CircleCI-Public/circleci-demo-aws-ecs-ecr.svg "CircleCI status")](https://circleci.com/gh/CircleCI-Public/circleci-demo-aws-ecs-ecr)

## Alternative branches
* [More advanced example with Orbs](https://github.com/CircleCI-Public/circleci-demo-aws-ecs-ecr/tree/orbs)
* [Without Orbs](https://github.com/CircleCI-Public/circleci-demo-aws-ecs-ecr/tree/without_orbs)

## Prerequisites
### Set up required AWS resources
Builds of this project rely on AWS resources to be present in order to succeed. For convenience, the prerequisite AWS resources may be created using the terraform scripts procided in the `terraform_setup` directory.
1. Create a free [AWS account](https://portal.aws.amazon.com/billing/signup#/start).
2. Create an AWS user with the below permissions:
* IAMFullAccess
* AutoScalingFullAccess
* ElasticLoadBalancingFullAccess
* AmazonEC2ContainerRegistryFullAccess
* AmazonEC2ContainerServiceFullAccess
* AmazonVPCFullAccess
3. Create a free [Terraform Cloud](https://app.terraform.io/signup/account) account.
4. Create a new Workspace in Terraform Cloud and create the below environment variables listed in the table below.
5. Fork this repo and link your Repo to your new Workspace.


### Configure environment variables on CircleCI and Terraform Cloud
The following [environment variables](https://circleci.com/docs/2.0/env-vars/#setting-an-environment-variable-in-a-project) must be set for the project on CircleCI via the project settings page, before the project can be built successfully.


| Terraform Variable             | Description                                               |
| ------------------------------ | --------------------------------------------------------- |
| `aws_account_id`               | Used for ECR location                                     |

| Terraform Environment Variable | Description                                               |
| ------------------------------ | --------------------------------------------------------- |
| `AWS_ACCESS_KEY_ID`        | AWS Access Key for Access                                         |
| `AWS_SECRET_ACCESS_KEY`    | AWS Secret Access Key for Access                                  |
| `AWS_REGION`               | AWS Region                                                        |

| CircleCI Variable              | Description                                               |
| ------------------------------ | --------------------------------------------------------- |
| `AWS_ACCESS_KEY_ID`            | Used by the AWS CLI                                       |
| `AWS_SECRET_ACCESS_KEY `       | Used by the AWS CLI                                       |
| `AWS_DEFAULT_REGION`           | Used by the AWS CLI. Example value: "us-east-1" (Please make sure the specified region is supported by the Fargate launch type)                          |
| `AWS_ACCOUNT_ID`               | AWS account id. This information is required for deployment.                                   |
| `AWS_RESOURCE_NAME_PREFIX`     | Prefix that some of the required AWS resources are assumed to have in their names. The value should correspond to the `aws_resource_prefix` variable value in `terraform_setup/terraform.tfvars`.                             |

## Useful Links & References
- https://circleci.com/orbs/registry/orb/circleci/aws-ecr
- https://circleci.com/orbs/registry/orb/circleci/aws-ecs
- https://github.com/CircleCI-Public/aws-ecr-orb
- https://github.com/CircleCI-Public/aws-ecs-orb
- https://github.com/awslabs/aws-cloudformation-templates
- https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_GetStarted.html
