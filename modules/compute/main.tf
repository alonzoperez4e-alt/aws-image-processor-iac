data "archive_file" "upload_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambda/upload"
  output_path = "${path.module}/../../lambda/upload_payload.zip"
}

data "archive_file" "crop_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambda/crop"
  output_path = "${path.module}/../../lambda/crop_payload.zip"
}

# --- Roles de IAM ---

# 1. Upload Lambda Role
resource "aws_iam_role" "upload_role" {
  name = "upload-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "upload_basic_execution" {
  role       = aws_iam_role.upload_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "upload_vpc_access" {
  role       = aws_iam_role.upload_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "upload_s3_inline" {
  name = "upload-s3-put-${var.environment}"
  role = aws_iam_role.upload_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject"]
      Resource = ["${var.bucket_arn}/uploads/*"]
    }]
  })
}

# 2. Crop Lambda Role
resource "aws_iam_role" "crop_role" {
  name = "crop-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "crop_basic_execution" {
  role       = aws_iam_role.crop_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "crop_vpc_access" {
  role       = aws_iam_role.crop_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "crop_inline_policy" {
  name = "crop-permissions-${var.environment}"
  role = aws_iam_role.crop_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = ["${var.bucket_arn}/uploads/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = ["${var.bucket_arn}/processed/*"]
      },
      {
        Effect   = "Allow"
        Action   = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = [var.sqs_main_queue_arn]
      }
    ]
  })
}

# --- Funciones Lambda ---

resource "aws_lambda_function" "upload" {
  function_name    = "image-processor-${var.environment}-upload"
  role             = aws_iam_role.upload_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  memory_size      = var.lambda_upload_memory
  timeout          = 30
  filename         = data.archive_file.upload_zip.output_path
  source_code_hash = data.archive_file.upload_zip.output_base64sha256

  environment {
    variables = {
      S3_BUCKET     = var.bucket_id
      UPLOAD_PREFIX = "uploads/"
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.sg_upload_lambda_id]
  }
}

resource "aws_lambda_function" "crop" {
  function_name    = "image-processor-${var.environment}-crop"
  role             = aws_iam_role.crop_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  memory_size      = var.lambda_crop_memory
  timeout          = 60
  filename         = data.archive_file.crop_zip.output_path
  source_code_hash = data.archive_file.crop_zip.output_base64sha256

  environment {
    variables = {
      S3_BUCKET        = var.bucket_id
      PROCESSED_PREFIX = "processed/"
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.sg_crop_lambda_id]
  }
}

# --- Event Source Mapping ---
resource "aws_lambda_event_source_mapping" "sqs_to_crop" {
  event_source_arn        = var.sqs_main_queue_arn
  function_name           = aws_lambda_function.crop.arn
  batch_size              = 5
  function_response_types = ["ReportBatchItemFailures"]
}