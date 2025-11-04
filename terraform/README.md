# 🏗️ Infraestructura como Código - AKS Hola Mundo

Esta carpeta contiene la definición completa de la infraestructura de Azure usando **Terraform**, siguiendo las mejores prácticas de DevOps.

## 📂 Estructura del Proyecto

```
terraform/
├── modules/                    # Módulos reutilizables
│   ├── resource-group/        # Módulo de Resource Group
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── acr/                   # Módulo de Azure Container Registry
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── aks/                   # Módulo de Azure Kubernetes Service
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── key-vault/             # Módulo de Azure Key Vault
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── environments/              # Configuraciones por entorno
    ├── dev/                   # Desarrollo
    │   ├── providers.tf       # Configuración de providers y backend
    │   ├── main.tf           # Orquestación de módulos
    │   ├── variables.tf      # Variables del entorno
    │   └── outputs.tf        # Outputs del entorno
    └── prod/                  # Producción (para el futuro)
```

## 🎯 Características de los Módulos

### 📦 Resource Group Module
- Creación de Resource Groups con tags estandarizados
- Lifecycle management
- Outputs: ID, nombre, ubicación

### 🐳 ACR Module
- Soporte para SKUs: Basic, Standard, Premium
- Configuración de identidad administrada
- Integración automática con AKS (role assignment AcrPull)
- Network ACLs y seguridad
- Geo-replicación (Premium)
- Políticas de retención y trust

### ☸️ AKS Module
- Node pools configurables (default + adicionales)
- Auto-scaling opcional
- Network profiles (kubenet, Azure CNI)
- Network policies (Calico, Azure)
- Azure AD RBAC integration
- Azure Monitor y Azure Policy
- Maintenance windows
- API server access restrictions
- Integración automática con ACR

### 🔐 Key Vault Module
- Soft delete y purge protection
- Network ACLs
- Access Policies o Azure RBAC
- Creación automática de secretos
- Outputs seguros (sensitive)

## 🚀 Uso Rápido

### Prerrequisitos

1. **Terraform** instalado (>= 1.5.0)
   ```bash
   terraform version
   ```

2. **Azure CLI** instalado y autenticado
   ```bash
   az login
   az account show
   ```

3. Seleccionar suscripción correcta
   ```bash
   az account set --subscription "YOUR_SUBSCRIPTION_ID"
   ```

### Despliegue del Entorno de Desarrollo

```bash
# 1. Navegar al entorno
cd terraform/environments/dev

# 2. Inicializar Terraform
terraform init

# 3. Revisar el plan de ejecución
terraform plan

# 4. Aplicar la infraestructura
terraform apply

# 5. Ver outputs
terraform output

# 6. Ver comandos útiles
terraform output -raw commands
```

### Variables Personalizables

Edita `environments/dev/variables.tf` o crea un archivo `terraform.tfvars`:

```hcl
project_name = "holamundo"
environment  = "dev"
location     = "eastus"

aks_node_count          = 2
aks_vm_size             = "Standard_D2s_v3"
aks_enable_auto_scaling = true
aks_min_count           = 1
aks_max_count           = 5

acr_sku = "Standard"

kv_secrets = {
  hello-greeting = "Mi mensaje personalizado"
  app-config     = "valor-de-configuracion"
}
```

## 🔄 Workflow Recomendado

### 1. Desarrollo Local

```bash
# Validar sintaxis
terraform fmt -recursive
terraform validate

# Plan con archivo de salida
terraform plan -out=tfplan

# Aplicar plan guardado
terraform apply tfplan
```

### 2. Destruir Recursos (Cuidado)

```bash
# Destruir entorno completo
terraform destroy

# Destruir recursos específicos
terraform destroy -target=module.aks
```

### 3. State Management

```bash
# Ver estado actual
terraform state list

# Ver detalles de un recurso
terraform state show module.aks.azurerm_kubernetes_cluster.this

# Mover recursos en el state
terraform state mv module.old_name module.new_name
```

## 🏢 Backend Remoto (Recomendado para Equipos)

### Configurar Azure Storage como Backend

1. **Crear recursos para el state**:

```bash
# Variables
RESOURCE_GROUP_NAME="rg-terraform-state"
STORAGE_ACCOUNT_NAME="sttfstateholamundo"
CONTAINER_NAME="tfstate"
LOCATION="eastus"

# Crear Resource Group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Crear Storage Account
az storage account create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $STORAGE_ACCOUNT_NAME \
  --sku Standard_LRS \
  --encryption-services blob

# Crear Container
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME
```

2. **Descomentar backend en `providers.tf`**:

```hcl
backend "azurerm" {
  resource_group_name  = "rg-terraform-state"
  storage_account_name = "sttfstateholamundo"
  container_name       = "tfstate"
  key                  = "dev/terraform.tfstate"
}
```

3. **Re-inicializar Terraform**:

```bash
terraform init -migrate-state
```

## 🔐 Seguridad y Mejores Prácticas

### ✅ Implementadas

- ✅ Identidades administradas (no credenciales hardcodeadas)
- ✅ RBAC para integración AKS-ACR
- ✅ Soft delete en Key Vault
- ✅ Tags estandarizados en todos los recursos
- ✅ Outputs sensibles marcados como `sensitive`
- ✅ Validaciones en variables
- ✅ Network policies en AKS
- ✅ Módulos reutilizables y versionables

### 🔒 Recomendaciones Adicionales

1. **State Encryption**: Usar backend remoto con cifrado
2. **Secrets Management**: No guardar secretos en código
   ```bash
   export TF_VAR_kv_secrets='{"key": "value"}'
   ```
3. **Permisos Mínimos**: Usar Service Principal con permisos específicos
4. **Purge Protection**: Habilitar en Key Vault para producción
5. **Geo-redundancia**: Usar SKU Premium de ACR en producción
6. **Private Endpoints**: Configurar para ACR y Key Vault en prod

## 📊 Outputs del Despliegue

Después de `terraform apply`, obtendrás:

```bash
# Ver todos los outputs
terraform output

# Output específico
terraform output acr_login_server
terraform output aks_name

# Output sensible
terraform output -raw aks_kube_config > ~/.kube/config-aks-dev
```

### Conectar a AKS Directamente

```bash
# Usando az CLI (recomendado)
RG=$(terraform output -raw resource_group_name)
AKS=$(terraform output -raw aks_name)
az aks get-credentials --resource-group $RG --name $AKS --overwrite-existing

# Verificar conexión
kubectl get nodes
kubectl cluster-info
```

## 🔄 Actualización de la Infraestructura

### Escalar el Cluster

```bash
# Editar variables.tf o crear tfvars
cat > terraform.tfvars <<EOF
aks_node_count = 3
aks_enable_auto_scaling = true
aks_max_count = 5
EOF

# Aplicar cambios
terraform plan
terraform apply
```

### Actualizar Versión de Kubernetes

```bash
# Ver versiones disponibles
az aks get-versions --location eastus -o table

# Actualizar variable
echo 'aks_kubernetes_version = "1.28.3"' >> terraform.tfvars

terraform apply
```

## 🧪 Testing

### Validar Módulos

```bash
# Validar todos los módulos
for dir in modules/*; do
  echo "Validating $dir..."
  cd $dir && terraform init -backend=false && terraform validate && cd -
done
```

### Dry-run Completo

```bash
terraform plan -detailed-exitcode
# Exit codes: 0=no changes, 1=error, 2=changes pending
```

## 📚 Recursos Adicionales

- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [AKS Best Practices](https://learn.microsoft.com/azure/aks/best-practices)
- [Terraform Modules](https://developer.hashicorp.com/terraform/language/modules)
- [Azure Naming Conventions](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)

## 🐛 Troubleshooting

### Error: Backend initialization required

```bash
rm -rf .terraform .terraform.lock.hcl
terraform init
```

### Error: State lock

```bash
# Forzar unlock (usar con cuidado)
terraform force-unlock <LOCK_ID>
```

### Error: Insufficient permissions

```bash
# Verificar permisos actuales
az role assignment list --assignee $(az account show --query user.name -o tsv)

# Asignar rol de Contributor
az role assignment create \
  --role Contributor \
  --assignee <principal-id> \
  --scope /subscriptions/<subscription-id>
```

## 📝 Notas

- Los errores de lint en los módulos son normales hasta que se invoquen desde `main.tf`
- El timestamp en tags cambia con cada apply (puedes ignorarlo con lifecycle)
- El backend local (por defecto) guarda el state en `terraform.tfstate` - **NO hacer commit**
- Para producción, considera:
  - Backend remoto con lock
  - Workspaces de Terraform
  - CI/CD pipeline para aplicar cambios
  - Branch protection en el repo

---

**🎉 ¡Infraestructura lista para usar!**

Creado con ❤️ por el equipo DevOps
