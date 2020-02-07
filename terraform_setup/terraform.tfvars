# Please fill in the values for all the variables here

#aws_access_key = "${AWS_ACCESS_KEY_ID}"
#aws_secret_key = "${AWS_SECRET_ACCESS_KEY}"
#aws_account_id = "${AWS_ACCOUNT_ID}"
# e.g. us-east-1 (Please specify a region supported by Fargate launch type)
#aws_region     = "${AWS_DEFAULT_REGION}"
# Prefix to be used in the naming of some of the created AWS resources. Example value: demo-webapp
aws_resource_prefix = "cwvlug-circleci-demo"
aws_vpc_cidr_block           = "10.0.0.0/16"
aws_vpc_public_sn_01_cidr_block = "10.0.1.0/24"
aws_vpc_public_sn_02_cidr_block = "10.0.2.0/24"