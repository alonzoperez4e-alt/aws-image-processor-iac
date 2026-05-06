terraform {
  backend "s3" {
    bucket         = "tf-state-image-processor"
    key            = "envs/qa/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-lock-image-processor"
    encrypt        = true
  }
  provider "aws" {      # Configuración del proveedor de AWS
  region = var.region
}

module "networking" {
  source            = "../../modules/networking"
  environment       = var.environment
  region            = var.region
  vpc_cidr          = "10.0.0.0/16"
  az_a              = "${var.region}a"
  az_b              = "${var.region}b"
  nat_gateway_count = var.nat_gateway_count
}

module "messaging" {
  source      = "../../modules/messaging"
  environment = var.environment
  bucket_arn  = module.storage.bucket_arn 
}

module "storage" {
  source        = "../../modules/storage"
  environment   = var.environment
  sqs_queue_arn = module.messaging.main_queue_arn
}
      
module "observability" {
  source             = "../../modules/observability"
  environment        = var.environment
  log_retention_days = var.log_retention_days
}

module "compute" {
  source               = "../../modules/compute"
  environment          = var.environment
  bucket_id            = module.storage.bucket_id
  bucket_arn           = module.storage.bucket_arn
  sqs_main_queue_arn   = module.messaging.main_queue_arn
  private_subnet_ids   = module.networking.private_subnet_ids
  sg_upload_lambda_id  = module.networking.sg_upload_lambda_id
  sg_crop_lambda_id    = module.networking.sg_crop_lambda_id
  lambda_upload_memory = var.lambda_upload_memory
  lambda_crop_memory   = var.lambda_crop_memory
}

module "apigw" {
  source                      = "../../modules/apigw"
  environment                 = var.environment
  upload_lambda_arn           = module.compute.upload_lambda_arn
  upload_lambda_function_name = module.compute.upload_lambda_function_name
  apigw_log_group_arn         = module.observability.apigw_log_group_arn
  api_throttle_rps            = var.api_throttle_rps
}

output "api_url" {
  value = module.apigw.api_endpoint
}
}