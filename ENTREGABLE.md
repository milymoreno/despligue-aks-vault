# Despliegue Seguro de Microservicio "Hola Mundo" en AKS

## Resumen del Proyecto

Se ha implementado exitosamente un microservicio "Hola Mundo" desplegado en Azure Kubernetes Service (AKS) con gestión automatizada mediante GitHub Actions y secretos gestionados de forma segura.

## Componentes Implementados

### 1. Microservicio
- **Tecnología**: Node.js 18
- **Endpoint**: `/` (raíz)
- **Puerto**: 8080
- **Funcionalidad**: Retorna un mensaje de saludo obtenido desde una variable de entorno `APP_MESSAGE`
- **Archivo**: `server.js`

### 2. Dockerización
- **Dockerfile multi-stage** con imagen base Alpine
- **Usuario no-root** (appuser, UID 1000) para seguridad
- **Tamaño optimizado**: ~45 MB
- **Registry**: Azure Container Registry (holamundoacr.azurecr.io)

### 3. Repositorio y Pipeline
- **Repositorio**: https://github.com/milymoreno/despligue-aks-vault
- **Pipeline**: GitHub Actions (`.github/workflows/deploy.yml`)
- **Automatización**:
  - Build de imagen Docker
  - Push a ACR
  - Autenticación en Azure
  - Despliegue en AKS

### 4. Infraestructura Azure
- **Cluster AKS**: aks-holamundo-dev (región Central US)
- **Resource Group**: rg-aks-holamundo-dev
- **Azure Container Registry**: holamundoacr.azurecr.io
- **Kubernetes Version**: 1.32

### 5. Gestión de Secretos
- **Secret de Kubernetes**: `app-secret`
- **Variable**: `APP_MESSAGE="Hola desde Azure Key Vault!"`
- **Inyección**: Variable de entorno en el contenedor
- **Gestión**: Automatizada mediante GitHub Actions

### 6. Manifiestos Kubernetes

**Deployment** (`k8s/deployment.yaml`):
- 1 réplica
- Health probes (readiness y liveness)
- Security context (runAsNonRoot, runAsUser: 1000)
- Resource limits (CPU: 100m, Memory: 128Mi)

**Service** (`k8s/service.yaml`):
- Tipo: LoadBalancer
- Puerto: 80 → 8080
- IP Externa: 172.168.48.42

## Verificación del Despliegue

### Comando de prueba:
```bash
curl http://172.168.48.42
```

### Respuesta:
```
Hola desde Azure Key Vault!
```

## Evidencias
- ✅ Pipeline ejecutado exitosamente en GitHub Actions
- ✅ Imagen Docker construida y almacenada en ACR
- ✅ Aplicación desplegada en AKS
- ✅ Endpoint accesible públicamente
- ✅ Mensaje del secreto retornado correctamente

## Archivos de Configuración Entregados

1. **azure-pipelines.yml** - Pipeline de Azure DevOps (referencia)
2. **.github/workflows/deploy.yml** - GitHub Actions workflow
3. **k8s/deployment.yaml** - Manifiesto de Kubernetes para Deployment
4. **k8s/service.yaml** - Manifiesto de Kubernetes para Service
5. **Dockerfile** - Configuración de contenedor
6. **server.js** - Código del microservicio
7. **README.md** - Documentación completa del proyecto
8. **terraform/** - Infraestructura como código (IaC) completa con módulos

## Estructura del Proyecto

```
aks-holamundo/
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions pipeline
├── k8s/
│   ├── deployment.yaml         # Kubernetes Deployment
│   └── service.yaml            # Kubernetes Service
├── terraform/
│   ├── modules/
│   │   ├── resource-group/
│   │   ├── acr/
│   │   ├── aks/
│   │   └── key-vault/
│   └── environments/
│       └── dev/
├── Dockerfile                  # Imagen Docker
├── server.js                   # Microservicio Node.js
├── package.json
└── README.md                   # Documentación
```

## Proceso de CI/CD

### GitHub Actions Workflow

1. **Build Stage**:
   - Checkout del código
   - Login en ACR con credenciales
   - Build de imagen Docker
   - Push a Azure Container Registry
   - Tag: commit SHA y latest

2. **Deploy Stage**:
   - Autenticación en Azure con Service Principal
   - Obtención de credenciales de AKS
   - Creación/actualización del Secret de Kubernetes
   - Aplicación de manifiestos K8s
   - Actualización de imagen del deployment
   - Verificación del rollout
   - Listado de servicios

## Secrets Configurados en GitHub

- `AZURE_CREDENTIALS` - Service Principal para autenticación en Azure
- `ACR_USERNAME` - Usuario de Azure Container Registry
- `ACR_PASSWORD` - Contraseña de Azure Container Registry
- `APP_MESSAGE` - Mensaje del microservicio

## Comandos de Verificación

### Ver pods en ejecución:
```bash
kubectl get pods -n default
```

### Ver servicios:
```bash
kubectl get svc -n default
```

### Ver logs del microservicio:
```bash
kubectl logs -n default -l app=holamundo
```

### Probar el endpoint:
```bash
curl http://172.168.48.42
# Respuesta: Hola desde Azure Key Vault!
```

## Capturas de Pantalla

- **GitHub Actions**: Workflow ejecutado exitosamente
- **Respuesta del endpoint**: Mensaje "Hola desde Azure Key Vault!"
- **Kubernetes Dashboard**: Pods y servicios desplegados

---

**Fecha de entrega**: 4 de noviembre de 2025  
**Repositorio**: https://github.com/milymoreno/despligue-aks-vault  
**Estado**: ✅ Completado exitosamente
