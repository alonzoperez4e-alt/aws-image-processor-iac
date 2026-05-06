variable "environment" {
  description = "Entorno de despliegue (dev, qa, prod)"
  type        = string
}

variable "bucket_id" {
  description = "Nombre del bucket S3"
  type        = string
}

variable "bucket_arn" {
  description = "ARN del bucket S3"
  type        = string
}

variable "sqs_main_queue_arn" {
  description = "ARN de la cola SQS principal"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs de las subredes privadas para la VPC de Lambda"
  type        = list(string)
}

variable "sg_upload_lambda_id" {
  description = "Security Group ID para la Lambda Upload"
  type        = string
}

variable "sg_crop_lambda_id" {
  description = "Security Group ID para la Lambda Crop"
  type        = string
}

variable "lambda_upload_memory" {
  description = "Memoria asignada a la Lambda Upload"
  type        = number
  default     = 256
}

variable "lambda_crop_memory" {
  description = "Memoria asignada a la Lambda Crop"
  type        = number
  default     = 512
}