resource "aws_cloudwatch_metric_alarm" "lambda_errors_alarm" {
  alarm_name                = var.lambda_errors_alarm_name
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "Invocations"
  namespace                 = "AWS/Lambda"
  period                    = var.lambda_errors_alarm_period
  statistic                 = "Average"
  threshold                 = var.lambda_errors_alarm_threshold
  datapoints_to_alarm       = 1
  alarm_description         = var.lambda_errors_alarm_description
  insufficient_data_actions = []
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.lambda_alerts.arn]

  dimensions = {
    FunctionName = var.function_name
    Resource     = var.function_name
  }
}

resource "aws_sns_topic" "lambda_alerts" {
  name                                     = var.lambda_alerts_topic_name
  application_success_feedback_sample_rate = 0
  firehose_success_feedback_sample_rate    = 0
  http_success_feedback_sample_rate        = 0
  lambda_success_feedback_sample_rate      = 0
  sqs_success_feedback_sample_rate         = 0
  policy                                   = var.lambda_alerts_topic_policy
}

resource "aws_sns_topic_subscription" "lambda_errors_email" {
  topic_arn = aws_sns_topic.lambda_alerts.arn
  protocol  = "email"
  endpoint  = var.lambda_errors_email_endpoint
}

resource "aws_cloudwatch_metric_alarm" "billing_alert" {
  alarm_name                = var.billing_alert_name
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "EstimatedCharges"
  namespace                 = "AWS/Billing"
  period                    = var.billing_alert_period
  statistic                 = "Maximum"
  threshold                 = var.billing_alert_threshold
  alarm_description         = var.billing_alert_description
  datapoints_to_alarm       = 1
  tags                      = {}
  insufficient_data_actions = []
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.billing_alerts.arn]

  dimensions = {
    Currency = "USD"
  }
}

resource "aws_sns_topic" "billing_alerts" {
  name                                     = var.billing_alerts_topic_name
  application_success_feedback_sample_rate = 0
  firehose_success_feedback_sample_rate    = 0
  http_success_feedback_sample_rate        = 0
  lambda_success_feedback_sample_rate      = 0
  sqs_success_feedback_sample_rate         = 0
  policy                                   = var.billing_alerts_topic_policy
}

resource "aws_sns_topic_subscription" "billing_alerts_email" {
  topic_arn = aws_sns_topic.billing_alerts.arn
  protocol  = "email"
  endpoint  = var.billing_alerts_email_endpoint
}
