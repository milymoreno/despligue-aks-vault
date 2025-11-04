variable "name" {
  description = "Nombre del Key Vault (debe ser globalmente único)"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.name))
    error_message = "El nombre debe tener entre 3 y 24 caracteres y solo puede contener letras, números y guiones."
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

variable "sku_name" {
  description = "SKU del Key Vault (standard o premium)"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "El SKU debe ser standard o premium."
  }
}

variable "soft_delete_retention_days" {
  description = "Días de retención para soft delete (7-90)"
  type        = number
  default     = 90
  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Los días de retención deben estar entre 7 y 90."
  }
}

variable "purge_protection_enabled" {
  description = "Habilitar protección contra purga (recomendado para producción)"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Permitir acceso desde redes públicas"
  type        = bool
  default     = true
}

variable "network_acls_enabled" {
  description = "Habilitar reglas de red ACL"
  type        = bool
  default     = false
}

variable "network_acls" {
  description = "Configuración de Network ACLs"
  type = object({
    bypass                     = string
    default_action             = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  default = {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
}

variable "enable_rbac_authorization" {
  description = "Usar Azure RBAC en lugar de Access Policies (recomendado)"
  type        = bool
  default     = false
}

variable "access_policies" {
  description = "Lista de access policies (solo si enable_rbac_authorization = false)"
  type = list(object({
    object_id               = string
    secret_permissions      = list(string)
    key_permissions         = list(string)
    certificate_permissions = list(string)
  }))
  default = []
}

variable "rbac_assignments" {
  description = "Lista de asignaciones RBAC (solo si enable_rbac_authorization = true)"
  type = list(object({
    principal_id         = string
    role_definition_name = string
  }))
  default = []
}

variable "secrets" {
  description = "Mapa de secretos a crear (clave = nombre del secreto, valor = contenido)"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "tags" {
  description = "Tags para el Key Vault"
  type        = map(string)
  default     = {}
}
