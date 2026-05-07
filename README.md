# AWS Image Processor IaC (Terraform)

Este proyecto despliega una arquitectura Serverless en AWS para el procesamiento de imágenes, utilizando Infraestructura como Código (IaC) con Terraform. Está diseñado para soportar múltiples entornos (DEV, QA, PROD).

## URL del Proyecto (API Gateway)

- **DEV Endpoint:** "https://um8r16cc8c.execute-api.us-east-1.amazonaws.com"

## Requisitos Previos

- Terraform >= 1.6
- AWS CLI v2 configurado con credenciales de administrador.
- Node.js 20.x

## Instrucciones de Despliegue

1. Navegar al entorno deseado (ej. DEV):
   \`\`\`bash
   cd envs/dev
   \`\`\`
2. Inicializar Terraform:
   \`\`\`bash
   terraform init
   \`\`\`
3. Revisar el plan de ejecución:
   \`\`\`bash
   terraform plan -out=tfplan.dev
   \`\`\`
4. Aplicar los cambios:
   \`\`\`bash
   terraform apply tfplan.dev
   \`\`\`

## Prueba de la API

Puedes probar la subida de una imagen (simulada) invocando directamente la Lambda, o haciendo un POST a la URL del API Gateway devuelta en los outputs.

\`\`\`bash
aws lambda invoke --function-name image-processor-dev-upload --payload '{}' response.json
\`\`\`

## Destrucción de la Infraestructura

Para evitar cobros, destruir los recursos una vez finalizadas las pruebas:
\`\`\`bash
terraform destroy

# Escribir 'yes' cuando se solicite

\`\`\`
