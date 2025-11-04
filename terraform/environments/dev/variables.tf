# ==========================================
# VARIABLES PRINCIPALES
# ==========================================

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "holamundo"
}

variable "environment" {
  description = "Entorno (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Región de Azure"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default = {
    Project     = "HolaMundo"
    Environment = "Development"
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
  }
}

# ==========================================
# AKS CONFIGURATION
# ==========================================

variable "aks_kubernetes_version" {
  description = "Versión de Kubernetes para AKS"
  type        = string
  default     = null # Usa la última estable
}

variable "aks_node_count" {
  description = "Número de nodos en el node pool por defecto"
  type        = number
  default     = 1
}

variable "aks_vm_size" {
  description = "Tamaño de VM para los nodos"
  type        = string
  default     = "Standard_B2s"
}

variable "aks_enable_auto_scaling" {
  description = "Habilitar auto-scaling en el node pool"
  type        = bool
  default     = false
}

variable "aks_min_count" {
  description = "Número mínimo de nodos (si auto-scaling está habilitado)"
  type        = number
  default     = 1
}

variable "aks_max_count" {
  description = "Número máximo de nodos (si auto-scaling está habilitado)"
  type        = number
  default     = 3
}

# ==========================================
# KEY VAULT CONFIGURATION
# ==========================================

variable "kv_sku_name" {
  description = "SKU del Key Vault"
  type        = string
  default     = "standard"
}

variable "kv_secrets" {
  description = "Secretos a crear en Key Vault"
  type        = map(string)
  default = {
    hello-greeting = "¡Hola Mundo desde Azure AKS con Terraform! 🚀"
  }
  sensitive = true
}

# ==========================================
# ACR CONFIGURATION
# ==========================================

variable "acr_sku" {
  description = "SKU del Azure Container Registry"
  type        = string
  default     = "Basic"
}

variable "acr_admin_enabled" {
  description = "Habilitar usuario admin en ACR"
  type        = bool
  default     = false
}
