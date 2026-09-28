# Serverless Image Processor — AWS & Terraform

Arquitectura orientada a eventos para carga y procesamiento asíncrono de imágenes desplegada con Terraform en AWS (us-east-1).

## Arquitectura

- **Ingesta:** API Gateway HTTP API v2 (`POST /upload`) con throttling configurado.
- **Cómputo:** Funciones AWS Lambda (`upload-lambda` y `crop-lambda`) en Node.js 20.x dentro de subredes privadas en dos Zonas de Disponibilidad (Multi-AZ).
- **Almacenamiento y Notificaciones:** Bucket Amazon S3 con cifrado SSE-AES256, versionado y políticas de ciclo de vida (`uploads/` 30 días, `processed/` 90 días). Event Notification hacia Amazon SQS con Dead-Letter Queue (DLQ).
- **Red:** VPC (`10.0.0.0/16`) con 2 subredes públicas (NAT Gateways), 2 subredes privadas, Gateway Endpoint para S3 e Interface Endpoint para SQS.
- **Monitoreo:** Alarmas de CloudWatch sobre mensajes visibles en la DLQ.

## Entornos Soportados

La solución utiliza Terraform Workspaces y archivos `.tfvars` para aislar los entornos:
- `DEV`: Límites de API throttling a 1,000 rps.
- `QA`: Límites de API throttling a 5,000 rps.
- `PROD`: Límites de API throttling a 10,000 rps.

## Instrucciones de Despliegue

### Requisitos Previos
- AWS CLI configurado con credenciales válidas en `us-east-1`.
- Terraform >= 1.5.0.

### Despliegue por Entorno

```bash
# 1. Inicializar
terraform init
 
# 2. Despliegue en DEV
terraform workspace create dev
terraform apply -var-file="environments/dev.tfvars"

# 3. Despliegue en QA
terraform workspace create qa
terraform apply -var-file="environments/qa.tfvars"

# 4. Despliegue en PROD
terraform workspace create prod
terraform apply -var-file="environments/prod.tfvars"

#Se siguen las indicaciones luego de cada apply y se marca el "Yes"
```
### Prueba funcional

curl.exe -X POST "https://xul9mowu41.execute-api.us-east-1.amazonaws.com/upload" -H "Content-Type: image/jpeg" --data-binary "Captura de pantalla 2026-09-28 090702.png"

# Destrucción del entorno
## En cada entorno funcional se despliega terraform destroy 
### terraform destroy -var-file="environments/'entorno'.tfvars" 
Se cambia 'entorno' por el respectivo 


# Si se habilitaron los 3 despliegues entonces hacer primero 
## terraform workspace select 'entorno'
Se cambia 'entorno' por el respectivo 


