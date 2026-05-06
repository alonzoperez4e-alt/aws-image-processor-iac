# --- Rol IAM para API Gateway ---
# Este rol permite a API Gateway enviar logs a CloudWatch a nivel de cuenta
resource "aws_iam_role" "apigw_cw_role" {
  name = "apigw-cloudwatch-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

# Adjuntar política administrada por AWS
resource "aws_iam_role_policy_attachment" "apigw_cw_policy" {
  role       = aws_iam_role.apigw_cw_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# Configuración de cuenta para API Gateway
resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.apigw_cw_role.arn
}

# --- Grupos de Logs en CloudWatch ---

# 1. Log Group para Lambda Upload
resource "aws_cloudwatch_log_group" "upload_lambda" {
  name              = "/aws/lambda/image-processor-${var.environment}-upload"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
  }
}

# 2. Log Group para Lambda Crop
resource "aws_cloudwatch_log_group" "crop_lambda" {
  name              = "/aws/lambda/image-processor-${var.environment}-crop"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
  }
}

# 3. Log Group para API Gateway
resource "aws_cloudwatch_log_group" "apigw" {
  name              = "/aws/apigateway/image-processor-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
  }
}