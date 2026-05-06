output "upload_lambda_arn" {
  description = "ARN de la función Lambda Upload"
  value       = aws_lambda_function.upload.arn
}

output "upload_lambda_function_name" {
  description = "Nombre de la función Lambda Upload"
  value       = aws_lambda_function.upload.function_name
}