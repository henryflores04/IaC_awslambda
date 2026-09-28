# Grupos de Logs
resource "aws_cloudwatch_log_group" "upload_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.upload.function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "crop_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.crop.function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "apigw" {
  name              = "/aws/apigateway/image-processor-${var.environment}-api"
  retention_in_days = 14
}

# Tópico SNS para alertas de DLQ
resource "aws_sns_topic" "alerts" {
  name = "image-processor-${var.environment}-dlq-alerts"
}

# Alarma DLQ
resource "aws_cloudwatch_metric_alarm" "dlq_alarm" {
  alarm_name          = "image-processor-${var.environment}-dlq-messages-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Mensajes acumulados en la Dead-Letter Queue"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    QueueName = aws_sqs_queue.dlq.name
  }
}