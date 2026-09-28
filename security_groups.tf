resource "aws_security_group" "upload_lambda" {
  name        = "upload-lambda-sg-${var.environment}"
  description = "Security group for upload Lambda"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "HTTPS to VPC Endpoints and NAT"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "image-processor-${var.environment}-sg-upload" }
}

resource "aws_security_group" "crop_lambda" {
  name        = "crop-lambda-sg-${var.environment}"
  description = "Security group for crop Lambda"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "HTTPS to VPC Endpoints and NAT"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "image-processor-${var.environment}-sg-crop" }
}

resource "aws_security_group" "vpce_sqs" {
  name        = "vpce-sqs-sg-${var.environment}"
  description = "Security group for SQS Interface Endpoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTPS from upload lambda"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.upload_lambda.id]
  }

  ingress {
    description     = "HTTPS from crop lambda"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.crop_lambda.id]
  }

  tags = { Name = "image-processor-${var.environment}-sg-vpce-sqs" }
}