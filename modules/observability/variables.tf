variable "environment" {
  description = "Entorno de despliegue (dev, qa, prod)"
  type        = string
}

variable "log_retention_days" {
  description = "Días de retención para los logs en CloudWatch"
  type        = number
  default     = 14
}