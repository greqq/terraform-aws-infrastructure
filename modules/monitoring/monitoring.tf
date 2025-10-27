# ============================================================================
# MONITORING MODULE - CloudWatch Alarms & SNS Notifications
# ============================================================================
# This module creates monitoring alerts for Lambda errors and AWS billing
#
# ALERTS CONFIGURED:
#   1. Lambda Errors: Triggers if >10 invocations in 5 minutes
#   2. Billing Alert: Triggers if AWS costs exceed $10
#
# ============================================================================

# Get current AWS account ID for use in policies
data "aws_caller_identity" "current" {}

# ============================================================================
# LAMBDA ERRORS ALARM
# ============================================================================
# Monitors Lambda function invocations to detect issues
# Triggers if function is called more than 10 times in 5 minutes
# This catches:
#   - Infinite loops calling API
#   - DDoS attacks
#   - Bot traffic
#   - Lambda errors causing retries
# ============================================================================

resource "aws_cloudwatch_metric_alarm" "lambda_errors_alarm" {
  alarm_name                = var.lambda_errors_alarm_name      # "API - Invocation alarm"
  comparison_operator       = "GreaterThanThreshold"            # Trigger if metric > threshold
  evaluation_periods        = "1"                               # Check 1 period
  metric_name               = "Invocations"                     # Lambda invocation count
  namespace                 = "AWS/Lambda"                      # AWS service namespace
  period                    = var.lambda_errors_alarm_period    # 300 seconds (5 minutes)
  statistic                 = "Average"                         # Use average value
  threshold                 = var.lambda_errors_alarm_threshold # 10 invocations
  datapoints_to_alarm       = 1                                 # Alarm after 1 data point
  alarm_description         = var.lambda_errors_alarm_description
  insufficient_data_actions = []                                # Don't alarm if no data
  actions_enabled           = true                              # Enable alarm actions
  alarm_actions             = [aws_sns_topic.lambda_alerts.arn] # Send to SNS topic

  dimensions = {
    FunctionName = var.function_name # "incrementCounter"
    Resource     = var.function_name
  }
}

# ============================================================================
# SNS TOPIC - Lambda Alerts
# ============================================================================
# Simple Notification Service (SNS) delivers alert messages
# ============================================================================

resource "aws_sns_topic" "lambda_alerts" {
  name                                     = var.lambda_alerts_topic_name # "CloudWatch_Alarms_Topic"
  application_success_feedback_sample_rate = 0                            # Disable success logs
  firehose_success_feedback_sample_rate    = 0
  http_success_feedback_sample_rate        = 0
  lambda_success_feedback_sample_rate      = 0
  sqs_success_feedback_sample_rate         = 0
}

# ============================================================================
# SNS TOPIC POLICY - Lambda Alerts
# ============================================================================
# Allows CloudWatch to publish messages to this SNS topic
# Without this: CloudWatch gets "AccessDenied"
# ============================================================================

resource "aws_sns_topic_policy" "lambda_alerts_policy" {
  arn = aws_sns_topic.lambda_alerts.arn
  policy = templatefile("../../modules/monitoring/sns_policy_template.tpl", {
    aws_account_id = data.aws_caller_identity.current.account_id,
    sns_topic_arn  = aws_sns_topic.lambda_alerts.arn
  })
}

# ============================================================================
# EMAIL SUBSCRIPTION - Lambda Alerts
# ============================================================================
# Sends Lambda alerts to your email
# ============================================================================

resource "aws_sns_topic_subscription" "lambda_errors_email" {
  topic_arn = aws_sns_topic.lambda_alerts.arn
  protocol  = "email"                          # Delivery method
  endpoint  = var.lambda_errors_email_endpoint
}

# ============================================================================
# BILLING ALARM
# ============================================================================
# Monitors AWS costs to prevent unexpected charges
# Triggers if monthly estimated charges exceed $10
# Checks every 6 hours for cost updates
# ============================================================================

resource "aws_cloudwatch_metric_alarm" "billing_alert" {
  alarm_name                = var.billing_alert_name      # "Billing alarm"
  comparison_operator       = "GreaterThanThreshold"      # Trigger if cost > threshold
  evaluation_periods        = "1"                         # Check 1 period
  metric_name               = "EstimatedCharges"          # AWS cost metric
  namespace                 = "AWS/Billing"               # Billing namespace
  period                    = var.billing_alert_period    # 21600 seconds (6 hours)
  statistic                 = "Maximum"                   # Use max value
  threshold                 = var.billing_alert_threshold # $10
  alarm_description         = var.billing_alert_description
  datapoints_to_alarm       = 1
  tags                      = {}
  insufficient_data_actions = []
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.billing_alerts.arn]

  dimensions = {
    Currency = "USD" # Monitor in US dollars
  }
}

# ============================================================================
# SNS TOPIC - Billing Alerts
# ============================================================================
# Separate topic for billing alerts (different from Lambda alerts)
# Allows different email destinations or notification methods
# ============================================================================

resource "aws_sns_topic" "billing_alerts" {
  name                                     = var.billing_alerts_topic_name # "CloudWatch_Billing"
  application_success_feedback_sample_rate = 0
  firehose_success_feedback_sample_rate    = 0
  http_success_feedback_sample_rate        = 0
  lambda_success_feedback_sample_rate      = 0
  sqs_success_feedback_sample_rate         = 0
}

# ============================================================================
# SNS TOPIC POLICY - Billing Alerts
# ============================================================================
# Allows CloudWatch Billing service to publish to this topic
# ============================================================================

resource "aws_sns_topic_policy" "billing_alerts_policy" {
  arn = aws_sns_topic.billing_alerts.arn
  policy = templatefile("../../modules/monitoring/sns_policy_template.tpl", {
    aws_account_id = data.aws_caller_identity.current.account_id,
    sns_topic_arn  = aws_sns_topic.billing_alerts.arn
  })
}

# ============================================================================
# EMAIL SUBSCRIPTION - Billing Alerts
# ============================================================================
# Sends billing alerts to your email
# IMPORTANT: Confirm subscription via email!
# ============================================================================

resource "aws_sns_topic_subscription" "billing_alerts_email" {
  topic_arn = aws_sns_topic.billing_alerts.arn
  protocol  = "email"
  endpoint  = var.billing_alerts_email_endpoint
}

