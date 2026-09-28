# Dead-Letter Queue
resource "aws_sqs_queue" "dlq" {
  name                      = "image-processor-${var.environment}-image-dlq"
  message_retention_seconds = 1209600 # 14 dias

  tags = { Name = "image-processor-${var.environment}-image-dlq" }
}

# Main Queue
resource "aws_sqs_queue" "main" {
  name                       = "image-processor-${var.environment}-image-queue"
  visibility_timeout_seconds = 360 # 6x timeout de crop-lambda (60s)
  message_retention_seconds  = 86400 # 1 dia
  receive_wait_time_seconds  = 20 # Long polling

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })

  tags = { Name = "image-processor-${var.environment}-image-queue" }
}

# Politica para permitir que S3 envie notificaciones a SQS
resource "aws_sqs_queue_policy" "main" {
  queue_url = aws_sqs_queue.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowS3ObjectCreated"
        Effect    = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.main.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.images.arn
          }
        }
      }
    ]
  })
}