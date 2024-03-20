module "instancerefresh_assume_role" {
  source     = "./modules/iams/assume_role"
  account_id = data.aws_caller_identity.current.account_id
  services   = ["lambda.amazonaws.com"]
}

resource "aws_iam_role" "instancerefresh_role" {
  name               = "instance-refresh"
  assume_role_policy = module.instancerefresh_assume_role.policy_document
  path               = "/"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
  ]

  inline_policy {
    name = "RefreshPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DetachInstances",
            "ec2:TerminateInstances",
            "ecs:DescribeClusters",
            "ecs:DescribeContainerInstances",
            "ecs:ListClusters",
            "ecs:ListContainerInstances",
            "ecs:UpdateContainerInstancesState",
          ]
          Resource = "*"
        },
      ]
    })
  }
}

module "scheduled_docker_lambda_instance_refresh" {
  source             = "./modules/scheduled_docker_lambda"
  account_id         = data.aws_caller_identity.current.account_id
  region             = data.aws_region.current.name
  private_subnet_ids = module.vpc-usw2-10-0.private_subnet_ids
  vpc_id             = module.vpc-usw2-10-0.vpc_id
  lambda_role_arn    = aws_iam_role.instancerefresh_role.arn
  timeout            = 600
  schedule_name      = "instance-refresh"
  docker_image       = "staging/instancerefresh:411b065f69a085cbe1c163eba52e7010d4e7bc26"
  schedules = {
    prod-asg = {
      description               = "Cycle machines in prod-asg"
      maximum_window_in_minutes = 120
      schedule_expression       = "rate(1 day)"
      payload = {
        asg_name    = module.prod_cluster.prod_asg_name,
        cluster_arn = module.prod_cluster.prod_cluster_arn,
      }
    }
    tailscale-asg = {
      description               = "Cycle machines in tailscale-asg"
      maximum_window_in_minutes = 120
      schedule_expression       = "rate(1 day)"
      payload = {
        asg_name    = module.tailscale-usw2-10-0.tailscale_asg_name,
        cluster_arn = "",
      }
    }
  }
}
