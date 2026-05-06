output "api_endpoint" {
  description = "URL pública del API Gateway"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}