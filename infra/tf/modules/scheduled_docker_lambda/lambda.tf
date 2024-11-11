module "lambda" {
  source                  = "../docker_lambda"
  account_id              = var.account_id
  region                  = var.region
  private_subnet_ids      = var.private_subnet_ids
  vpc_id                  = var.vpc_id
  timeout                 = var.timeout
  lambda_role_arn         = var.lambda_role_arn
  lambda_name             = var.schedule_name
  docker_image            = var.docker_image
  kms_cloudtrailwatch_arn = var.kms_cloudtrailwatch_arn
}

resource "aws_scheduler_schedule" "this" {
  for_each = toset(keys(var.schedules))

  name        = "${var.schedule_name}-${each.key}"
  description = var.schedules[each.value].description

  flexible_time_window {
    mode                      = "FLEXIBLE"
    maximum_window_in_minutes = var.schedules[each.value].maximum_window_in_minutes
  }

  schedule_expression = var.schedules[each.value].schedule_expression

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:lambda:invoke"
    role_arn = aws_iam_role.this.arn

    input = jsonencode({
      FunctionName   = module.lambda.lambda_arn,
      InvocationType = "Event",
      Payload        = jsonencode(var.schedules[each.value].payload)
    })
  }
}
