# 🚀 Hola Mundo AKS

Aplicación Node.js simple desplegada en Azure Kubernetes Service (AKS) con CI/CD automatizado.

## 📋 Descripción

Este proyecto demuestra un despliegue completo de una aplicación web en AKS utilizando:
- **Azure Container Registry (ACR)** para almacenar imágenes Docker
- **Azure Kubernetes Service (AKS)** como plataforma de orquestación
- **Azure Key Vault** para gestión segura de secretos
- **Azure Pipelines** para CI/CD automatizado

## 🏗️ Arquitectura

```
┌─────────────────┐
│ Azure DevOps    │
│ (CI/CD)         │
└────────┬────────┘
         │
         ├──► Build imagen (ACR Build)
         │    └─► Azure Container Registry
         │
         └──► Deploy
              ├─► Conectar AKS ←→ ACR
              ├─► Leer secreto desde Key Vault
              ├─► Aplicar manifiestos K8s
              └─► Rollout deployment
                  └─► Azure Kubernetes Service
                       └─► LoadBalancer (IP pública)
```

## 📁 Estructura del Proyecto

```
aks-holamundo/
├── server.js                 # Aplicación Node.js
├── package.json              # Dependencias y scripts
├── package-lock.json         # Lock file de dependencias
├── Dockerfile                # Imagen Docker con multi-stage y seguridad
├── .dockerignore             # Archivos excluidos del contexto Docker
├── azure-pipelines.yml       # Pipeline CI/CD
└── k8s/
    ├── deployment.yaml       # Deployment con probes y recursos
    └── service.yaml          # Service tipo LoadBalancer
```

## 🔧 Prerrequisitos

### En Azure

1. **Azure Subscription** activa
2. **Service Connection** en Azure DevOps:
   - Nombre: `azure-free-trial` (o ajustar en `azure-pipelines.yml`)
3. **Resource Group**: `rg-aks-holamundo-dev`
4. **AKS Cluster**: `aks-holamundo-dev`
5. **Container Registry**: `holamundoacr.azurecr.io`
6. **Key Vault**: `kv-holamundo-dev`
   - Secreto: `hello-greeting` con el mensaje personalizado

### En Local (para desarrollo)

- Node.js 18+
- Docker (opcional)
- kubectl (opcional)
- Azure CLI (opcional)

## 🚀 Inicio Rápido

### Ejecución Local

```bash
# Instalar dependencias
npm install

# Ejecutar servidor
npm start

# Probar
curl http://localhost:8080
```

### Ejecución con Docker

```bash
# Construir imagen
docker build -t holamundo:local .

# Ejecutar contenedor
docker run -p 8080:8080 -e APP_MESSAGE="Hola desde Docker 🐳" holamundo:local

# Probar
curl http://localhost:8080
```

## ☁️ Configuración en Azure

### 1. Crear Infraestructura

```bash
# Variables
RG="rg-aks-holamundo-dev"
LOCATION="eastus"
AKS_NAME="aks-holamundo-dev"
ACR_NAME="holamundoacr"
KV_NAME="kv-holamundo-dev"

# Resource Group
az group create --name $RG --location $LOCATION

# Container Registry
az acr create --resource-group $RG --name $ACR_NAME --sku Basic

# AKS Cluster
az aks create \
  --resource-group $RG \
  --name $AKS_NAME \
  --node-count 1 \
  --node-vm-size Standard_B2s \
  --enable-managed-identity \
  --attach-acr $ACR_NAME \
  --generate-ssh-keys

# Key Vault
az keyvault create --resource-group $RG --name $KV_NAME --location $LOCATION

# Crear secreto
az keyvault secret set \
  --vault-name $KV_NAME \
  --name hello-greeting \
  --value "¡Hola desde Azure Key Vault! 🔐"
```

### 2. Configurar Azure DevOps

1. Crear **Service Connection**:
   - Project Settings → Service connections → New service connection
   - Tipo: Azure Resource Manager
   - Scope: Subscription
   - Nombre: `azure-free-trial`

2. Crear **Pipeline**:
   - Pipelines → New pipeline → Azure Repos Git
   - Seleccionar repositorio
   - Existing Azure Pipelines YAML file: `/azure-pipelines.yml`

3. Ajustar **Variables** en `azure-pipelines.yml`:
   ```yaml
   variables:
     azureSubscription: 'azure-free-trial'    # Tu service connection
     resourceGroup: 'rg-aks-holamundo-dev'    # Tu resource group
     aksName: 'aks-holamundo-dev'             # Tu cluster AKS
     acrName: 'holamundoacr'                  # Tu ACR
     kvName: 'kv-holamundo-dev'               # Tu Key Vault
   ```

### 3. Permisos del Service Principal

El Service Principal de Azure DevOps necesita permisos en Key Vault:

```bash
# Obtener Object ID del Service Principal (desde Azure DevOps)
SP_OBJECT_ID="<object-id-from-service-connection>"

# Dar permisos de lectura en Key Vault
az keyvault set-policy \
  --name $KV_NAME \
  --object-id $SP_OBJECT_ID \
  --secret-permissions get list
```

## 📦 Pipeline CI/CD

El pipeline se ejecuta automáticamente en cada push a `main`/`master`:

### Stage 1: Build
1. Resuelve tag de imagen (commit SHA o Build ID)
2. Ejecuta `az acr build` (build server-side en ACR)
3. Publica imagen con dos tags: `<commit-sha>` y `latest`

### Stage 2: Deploy
1. Conecta AKS con ACR (attach-acr)
2. Obtiene credenciales del cluster AKS
3. Lee secreto desde Key Vault
4. Crea/actualiza Secret en Kubernetes
5. Aplica manifiestos (deployment.yaml, service.yaml)
6. Actualiza imagen del deployment con el nuevo tag
7. Espera rollout exitoso (timeout 5 min)
8. Muestra endpoints del servicio

## 🔍 Verificación del Despliegue

```bash
# Conectar a AKS
az aks get-credentials --resource-group rg-aks-holamundo-dev --name aks-holamundo-dev

# Ver pods
kubectl get pods

# Ver servicios (obtener IP pública del LoadBalancer)
kubectl get svc holamundo

# Ver logs
kubectl logs -l app=holamundo

# Probar aplicación
EXTERNAL_IP=$(kubectl get svc holamundo -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://$EXTERNAL_IP
```

## 🛡️ Características de Seguridad

### Dockerfile
- ✅ Usuario no-root (`appuser`)
- ✅ Imagen base Alpine (ligera)
- ✅ Multi-stage con cacheo de npm ci
- ✅ Solo dependencias de producción

### Kubernetes
- ✅ Security context: `runAsNonRoot: true`
- ✅ Resource limits (CPU/Memory)
- ✅ Readiness/Liveness probes
- ✅ Secretos desde Key Vault (no hardcodeados)
- ✅ Rolling updates con zero-downtime

### Pipeline
- ✅ ACR Build (server-side, sin exposición de credenciales)
- ✅ Attach-acr (sin image pull secrets manuales)
- ✅ Validación de secretos antes de crear K8s Secret
- ✅ Rollout con timeout y validación

## 🔧 Configuración Avanzada

### Variables de Entorno

Editar el secreto en Key Vault:

```bash
az keyvault secret set \
  --vault-name kv-holamundo-dev \
  --name hello-greeting \
  --value "Nuevo mensaje 🎉"

# Reiniciar deployment para aplicar cambios
kubectl rollout restart deployment/holamundo
```

### Escalar Replicas

```bash
# Escalar manualmente
kubectl scale deployment holamundo --replicas=3

# O editar deployment.yaml y hacer commit
```

### Cambiar a ClusterIP + Ingress

```yaml
# k8s/service.yaml
spec:
  type: ClusterIP  # Cambiar de LoadBalancer a ClusterIP
  # ... resto igual
```

Agregar `k8s/ingress.yaml` con certificado TLS.

## 📊 Monitoreo

### Logs en Tiempo Real
```bash
kubectl logs -f -l app=holamundo
```

### Estado del Cluster
```bash
kubectl top nodes
kubectl top pods
kubectl get events --sort-by='.lastTimestamp'
```

### Integración con Azure Monitor
Habilitar Container Insights en AKS para métricas avanzadas.

## 🐛 Troubleshooting

### Pods en CrashLoopBackOff
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name> --previous
```

### Secreto no se aplica
```bash
# Verificar que existe en K8s
kubectl get secret app-secret -o yaml

# Verificar permisos en Key Vault
az keyvault show --name kv-holamundo-dev
```

### Pipeline falla en ACR Build
- Verificar que Service Connection tiene permisos en ACR
- Revisar que `package-lock.json` existe en el repo

### LoadBalancer sin IP externa
```bash
# Esperar (puede tardar 2-5 min)
kubectl get svc holamundo --watch

# Verificar eventos
kubectl describe svc holamundo
```

## 🧹 Limpieza de Recursos

```bash
# Eliminar todo el resource group
az group delete --name rg-aks-holamundo-dev --yes --no-wait
```

## 📚 Referencias

- [Azure Kubernetes Service](https://learn.microsoft.com/azure/aks/)
- [Azure Container Registry](https://learn.microsoft.com/azure/container-registry/)
- [Azure Key Vault](https://learn.microsoft.com/azure/key-vault/)
- [Azure Pipelines YAML](https://learn.microsoft.com/azure/devops/pipelines/yaml-schema)

## 📄 Licencia

Este proyecto es un ejemplo educativo. Úsalo libremente.

---

**Nota**: Recuerda ajustar los nombres de recursos (RG, AKS, ACR, KV) según tu entorno antes de ejecutar.
