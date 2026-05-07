output "apigw_log_group_arn" {
  description = "ARN del grupo de logs para API Gateway"
  value       = aws_cloudwatch_log_group.apigw.arn
}