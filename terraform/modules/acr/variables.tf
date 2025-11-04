variable "name" {
  description = "Nombre del Azure Container Registry (solo alfanuméricos, sin guiones)"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.name))
    error_message = "El nombre del ACR solo puede contener caracteres alfanuméricos."
  }
}

variable "resource_group_name" {
  description = "Nombre del Resource Group"
  type        = string
}

variable "location" {
  description = "Región de Azure"
  type        = string
}

variable "sku" {
  description = "SKU del ACR (Basic, Standard, Premium)"
  type        = string
  default     = "Basic"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "El SKU debe ser Basic, Standard o Premium."
  }
}

variable "admin_enabled" {
  description = "Habilitar usuario admin (no recomendado para producción)"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Permitir acceso público"
  type        = bool
  default     = true
}

variable "network_rule_bypass_option" {
  description = "Bypass de reglas de red (AzureServices o None)"
  type        = string
  default     = "AzureServices"
}

variable "identity_enabled" {
  description = "Habilitar identidad administrada"
  type        = bool
  default     = true
}

variable "retention_policy_enabled" {
  description = "Habilitar política de retención (solo Premium)"
  type        = bool
  default     = false
}

variable "retention_policy_days" {
  description = "Días de retención para imágenes sin tags"
  type        = number
  default     = 7
}

variable "trust_policy_enabled" {
  description = "Habilitar Content Trust (solo Premium)"
  type        = bool
  default     = false
}

variable "georeplications" {
  description = "Lista de regiones para geo-replicación (solo Premium)"
  type = list(object({
    location                = string
    zone_redundancy_enabled = bool
    tags                    = map(string)
  }))
  default = []
}

variable "aks_principal_id" {
  description = "Principal ID del AKS para asignar rol AcrPull"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags para el ACR"
  type        = map(string)
  default     = {}
}
