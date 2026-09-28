output "api_upload_url" {
  description = "URL para invocar el endpoint POST /upload"
  value       = "${aws_apigatewayv2_api.http_api.api_endpoint}/upload"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.images.bucket
}

output "sqs_queue_url" {
  value = aws_sqs_queue.main.url
}

output "dlq_queue_url" {
  value = aws_sqs_queue.dlq.url
}