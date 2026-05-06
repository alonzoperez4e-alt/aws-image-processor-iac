variable "environment" {
  description = "Entorno de despliegue (dev, qa, prod)"
  type        = string
}

variable "upload_lambda_arn" {
  description = "ARN de la función Lambda Upload para la integración"
  type        = string
}

variable "upload_lambda_function_name" {
  description = "Nombre de la función Lambda Upload para otorgar permisos"
  type        = string
}

variable "apigw_log_group_arn" {
  description = "ARN del Log Group de CloudWatch para el API Gateway"
  type        = string
}

variable "api_throttle_rps" {
  description = "Límite de peticiones por segundo (RPS) para throttling"
  type        = number
}