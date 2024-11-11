
resource "aws_cloudwatch_log_metric_filter" "securityhub_filter" {
  name           = var.name
  log_group_name = var.log_group_name
  pattern        = var.filter_pattern
  metric_transformation {
    name          = var.name
    namespace     = "LogMetrics"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "securityhub_alarm" {
  alarm_name                = var.name
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = var.name
  namespace                 = "LogMetrics"
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = var.description
  actions_enabled           = true
  treat_missing_data        = "notBreaching"
  alarm_actions             = [var.sns_arn]
  ok_actions                = [var.sns_arn]
  insufficient_data_actions = []
  datapoints_to_alarm       = "1"
  dimensions = {
    MetricName = var.name
  }
}
