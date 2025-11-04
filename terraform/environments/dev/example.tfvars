# Ejemplo de archivo de variables para Terraform
# Copia este archivo a terraform.tfvars y personaliza los valores

# ==========================================
# CONFIGURACIÓN BÁSICA
# ==========================================

project_name = "holamundo"
environment  = "dev"
location     = "eastus"  # Otras opciones: westus, westeurope, etc.

# Tags personalizados
tags = {
  Project     = "HolaMundo"
  Environment = "Development"
  ManagedBy   = "Terraform"
  Owner       = "Tu Nombre"
  CostCenter  = "Engineering"
}

# ==========================================
# AKS CONFIGURATION
# ==========================================

# Versión específica de Kubernetes (o null para la última estable)
aks_kubernetes_version = null  # Ejemplo: "1.28.3"

# Configuración del node pool
aks_node_count          = 1
aks_vm_size             = "Standard_B2s"  # Standard_D2s_v3 para prod
aks_enable_auto_scaling = false
aks_min_count           = 1
aks_max_count           = 3

# ==========================================
# ACR CONFIGURATION
# ==========================================

acr_sku          = "Basic"  # Basic, Standard, Premium
acr_admin_enabled = false   # true solo para dev/testing

# ==========================================
# KEY VAULT CONFIGURATION
# ==========================================

kv_sku_name = "standard"  # standard o premium

# Secretos a crear en Key Vault
kv_secrets = {
  hello-greeting = "¡Hola Mundo desde Azure AKS con Terraform! 🚀"
  app-version    = "1.0.0"
  # Agrega más secretos aquí
}
