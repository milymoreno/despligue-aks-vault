resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  # Node pool por defecto (system)
  default_node_pool {
    name                = var.default_node_pool.name
    node_count          = var.default_node_pool.node_count
    vm_size             = var.default_node_pool.vm_size
    enable_auto_scaling = var.default_node_pool.enable_auto_scaling
    min_count           = var.default_node_pool.enable_auto_scaling ? var.default_node_pool.min_count : null
    max_count           = var.default_node_pool.enable_auto_scaling ? var.default_node_pool.max_count : null
    max_pods            = var.default_node_pool.max_pods
    os_disk_size_gb     = var.default_node_pool.os_disk_size_gb
    os_disk_type        = var.default_node_pool.os_disk_type
    type                = "VirtualMachineScaleSets"
    zones               = var.default_node_pool.availability_zones

    tags = var.tags
  }

  # Identidad administrada
  identity {
    type = "SystemAssigned"
  }

  # Configuración de red
  network_profile {
    network_plugin    = var.network_profile.network_plugin
    network_policy    = var.network_profile.network_policy
    dns_service_ip    = var.network_profile.dns_service_ip
    service_cidr      = var.network_profile.service_cidr
    load_balancer_sku = var.network_profile.load_balancer_sku
  }

  # Azure Active Directory RBAC
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.aad_rbac_enabled ? [1] : []
    content {
      managed                = true
      azure_rbac_enabled     = var.azure_rbac_enabled
      admin_group_object_ids = var.aad_admin_group_object_ids
    }
  }

  # Azure Monitor
  dynamic "oms_agent" {
    for_each = var.enable_azure_monitor ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  # Azure Policy
  dynamic "azure_policy_enabled" {
    for_each = var.enable_azure_policy ? [1] : true
    content {
      enabled = var.enable_azure_policy
    }
  }

  # Configuración de seguridad
  role_based_access_control_enabled = true
  
  # Actualización automática
  automatic_channel_upgrade = var.automatic_channel_upgrade

  # Mantenimiento
  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    content {
      allowed {
        day   = maintenance_window.value.day
        hours = maintenance_window.value.hours
      }
    }
  }

  # API Server Access Profile
  dynamic "api_server_access_profile" {
    for_each = var.api_server_authorized_ip_ranges != null ? [1] : []
    content {
      authorized_ip_ranges = var.api_server_authorized_ip_ranges
    }
  }

  tags = merge(
    var.tags,
    {
      ManagedBy = "Terraform"
    }
  )

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
}

# Node pools adicionales
resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  for_each = { for np in var.additional_node_pools : np.name => np }

  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  enable_auto_scaling   = each.value.enable_auto_scaling
  min_count             = each.value.enable_auto_scaling ? each.value.min_count : null
  max_count             = each.value.enable_auto_scaling ? each.value.max_count : null
  max_pods              = each.value.max_pods
  os_disk_size_gb       = each.value.os_disk_size_gb
  os_disk_type          = each.value.os_disk_type
  os_type               = each.value.os_type
  zones                 = each.value.availability_zones
  mode                  = each.value.mode

  node_labels = each.value.node_labels
  node_taints = each.value.node_taints

  tags = merge(var.tags, each.value.tags)

  lifecycle {
    ignore_changes = [node_count]
  }
}

# Asignación de rol para ACR pull (si se proporciona ACR ID)
resource "azurerm_role_assignment" "aks_acr_pull" {
  count                = var.acr_id != null ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = var.acr_id
  skip_service_principal_aad_check = true
}
