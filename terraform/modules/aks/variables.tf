variable "name" {
  description = "Nombre del cluster AKS"
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del Resource Group"
  type        = string
}

variable "location" {
  description = "Región de Azure"
  type        = string
}

variable "dns_prefix" {
  description = "Prefijo DNS para el cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Versión de Kubernetes"
  type        = string
  default     = null
}

variable "default_node_pool" {
  description = "Configuración del node pool por defecto"
  type = object({
    name                = string
    node_count          = number
    vm_size             = string
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
    max_pods            = number
    os_disk_size_gb     = number
    os_disk_type        = string
    availability_zones  = list(string)
  })
  default = {
    name                = "system"
    node_count          = 1
    vm_size             = "Standard_B2s"
    enable_auto_scaling = false
    min_count           = 1
    max_count           = 3
    max_pods            = 110
    os_disk_size_gb     = 30
    os_disk_type        = "Managed"
    availability_zones  = []
  }
}

variable "additional_node_pools" {
  description = "Lista de node pools adicionales"
  type = list(object({
    name                = string
    vm_size             = string
    node_count          = number
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
    max_pods            = number
    os_disk_size_gb     = number
    os_disk_type        = string
    os_type             = string
    availability_zones  = list(string)
    mode                = string
    node_labels         = map(string)
    node_taints         = list(string)
    tags                = map(string)
  }))
  default = []
}

variable "network_profile" {
  description = "Configuración de red del cluster"
  type = object({
    network_plugin    = string
    network_policy    = string
    dns_service_ip    = string
    service_cidr      = string
    load_balancer_sku = string
  })
  default = {
    network_plugin    = "kubenet"
    network_policy    = "calico"
    dns_service_ip    = "10.0.0.10"
    service_cidr      = "10.0.0.0/16"
    load_balancer_sku = "standard"
  }
}

variable "aad_rbac_enabled" {
  description = "Habilitar Azure AD RBAC"
  type        = bool
  default     = false
}

variable "azure_rbac_enabled" {
  description = "Habilitar Azure RBAC para autorizaciones de Kubernetes"
  type        = bool
  default     = false
}

variable "aad_admin_group_object_ids" {
  description = "Lista de Object IDs de grupos de Azure AD con permisos de admin"
  type        = list(string)
  default     = []
}

variable "enable_azure_monitor" {
  description = "Habilitar Azure Monitor para contenedores"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "ID del workspace de Log Analytics"
  type        = string
  default     = null
}

variable "enable_azure_policy" {
  description = "Habilitar Azure Policy"
  type        = bool
  default     = false
}

variable "automatic_channel_upgrade" {
  description = "Canal de actualización automática (patch, stable, rapid, node-image, none)"
  type        = string
  default     = "patch"
}

variable "maintenance_window" {
  description = "Ventana de mantenimiento"
  type = object({
    day   = string
    hours = list(number)
  })
  default = null
}

variable "api_server_authorized_ip_ranges" {
  description = "Rangos IP autorizados para acceder al API server"
  type        = list(string)
  default     = null
}

variable "acr_id" {
  description = "ID del Azure Container Registry para asignar permisos"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags para el cluster AKS"
  type        = map(string)
  default     = {}
}
