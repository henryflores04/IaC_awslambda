data "archive_file" "upload_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src/upload"
  output_path = "${path.module}/upload_payload.zip"
}

data "archive_file" "crop_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src/crop"
  output_path = "${path.module}/crop_payload.zip"
}

# Upload Lambda
resource "aws_lambda_function" "upload" {
  filename         = data.archive_file.upload_zip.output_path
  source_code_hash = data.archive_file.upload_zip.output_base64sha256
  function_name    = "image-processor-${var.environment}-upload"
  role             = aws_iam_role.upload_lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  memory_size      = 256
  timeout          = 30

  vpc_config {
    subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_group_ids = [aws_security_group.upload_lambda.id]
  }

  environment {
    variables = {
      S3_BUCKET     = aws_s3_bucket.images.bucket
      UPLOAD_PREFIX = "uploads/"
    }
  }

  depends_on = [aws_iam_role_policy_attachment.upload_vpc]
}

# Crop Lambda
resource "aws_lambda_function" "crop" {
  filename         = data.archive_file.crop_zip.output_path
  source_code_hash = data.archive_file.crop_zip.output_base64sha256
  function_name    = "image-processor-${var.environment}-crop"
  role             = aws_iam_role.crop_lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  memory_size      = 512
  timeout          = 60

  vpc_config {
    subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_group_ids = [aws_security_group.crop_lambda.id]
  }

  environment {
    variables = {
      S3_BUCKET        = aws_s3_bucket.images.bucket
      PROCESSED_PREFIX = "processed/"
    }
  }

  depends_on = [aws_iam_role_policy_attachment.crop_vpc]
}

# Event Source Mapping (SQS -> Crop Lambda)
resource "aws_lambda_event_source_mapping" "crop_sqs" {
  event_source_arn                   = aws_sqs_queue.main.arn
  function_name                      = aws_lambda_function.crop.arn
  batch_size                         = 5
  function_response_types            = ["ReportBatchItemFailures"]
}