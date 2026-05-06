environment          = "prod"
region               = "us-east-1"
nat_gateway_count    = 2          #  2 NAT para alta disponibilidad en PROD
lambda_upload_memory = 512        # Más memoria si esperamos ráfagas pesadas
lambda_crop_memory   = 1024       
api_throttle_rps     = 10000
log_retention_days   = 14