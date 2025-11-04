# ==========================================
# LOCALS
# ==========================================

locals {
  resource_prefix = "${var.project_name}-${var.environment}"
  
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Timestamp   = timestamp()
    }
  )
}

# ==========================================
# RESOURCE GROUP
# ==========================================

module "resource_group" {
  source = "../../modules/resource-group"

  name     = "rg-aks-${local.resource_prefix}"
  location = var.location
  tags     = local.common_tags
}

# ==========================================
# AZURE CONTAINER REGISTRY
# ==========================================

module "acr" {
  source = "../../modules/acr"

  name                = "${var.project_name}acr${var.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled
  identity_enabled    = true
  
  # Se asignará el rol después de crear AKS
  aks_principal_id = null

  tags = local.common_tags

  depends_on = [module.resource_group]
}

# ==========================================
# AZURE KUBERNETES SERVICE
# ==========================================

module "aks" {
  source = "../../modules/aks"

  name                = "aks-${local.resource_prefix}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  dns_prefix          = "${var.project_name}-${var.environment}"
  kubernetes_version  = var.aks_kubernetes_version

  default_node_pool = {
    name                = "system"
    node_count          = var.aks_node_count
    vm_size             = var.aks_vm_size
    enable_auto_scaling = var.aks_enable_auto_scaling
    min_count           = var.aks_min_count
    max_count           = var.aks_max_count
    max_pods            = 110
    os_disk_size_gb     = 30
    os_disk_type        = "Managed"
    availability_zones  = []
  }

  network_profile = {
    network_plugin    = "kubenet"
    network_policy    = "calico"
    dns_service_ip    = "10.0.0.10"
    service_cidr      = "10.0.0.0/16"
    load_balancer_sku = "standard"
  }

  # Integración con ACR
  acr_id = module.acr.id

  # Configuración de seguridad y monitoreo
  aad_rbac_enabled           = false
  enable_azure_monitor       = false
  enable_azure_policy        = false
  automatic_channel_upgrade  = "patch"

  tags = local.common_tags

  depends_on = [module.resource_group, module.acr]
}

# ==========================================
# AZURE KEY VAULT
# ==========================================

module "key_vault" {
  source = "../../modules/key-vault"

  name                = "kv-${var.project_name}-${var.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku_name            = var.kv_sku_name
  
  # Configuración de seguridad
  soft_delete_retention_days    = 90
  purge_protection_enabled      = false # true para producción
  public_network_access_enabled = true
  enable_rbac_authorization     = false
  
  # Secretos
  secrets = var.kv_secrets

  # Access policy para AKS (usando kubelet identity)
  access_policies = [
    {
      object_id = module.aks.kubelet_identity[0].object_id
      secret_permissions = [
        "Get",
        "List"
      ]
      key_permissions         = []
      certificate_permissions = []
    }
  ]

  tags = local.common_tags

  depends_on = [module.resource_group, module.aks]
}
