resource "azurerm_container_registry" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  # Configuración de red
  public_network_access_enabled = var.public_network_access_enabled
  network_rule_bypass_option    = var.network_rule_bypass_option

  # Configuración de seguridad
  dynamic "identity" {
    for_each = var.identity_enabled ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  # Retención de imágenes
  dynamic "retention_policy" {
    for_each = var.sku == "Premium" && var.retention_policy_enabled ? [1] : []
    content {
      days    = var.retention_policy_days
      enabled = true
    }
  }

  # Confianza de contenido (solo Premium)
  dynamic "trust_policy" {
    for_each = var.sku == "Premium" && var.trust_policy_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  # Geo-replicación (solo Premium)
  dynamic "georeplications" {
    for_each = var.sku == "Premium" ? var.georeplications : []
    content {
      location                = georeplications.value.location
      zone_redundancy_enabled = georeplications.value.zone_redundancy_enabled
      tags                    = georeplications.value.tags
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
  }
}

# Role assignment para permitir a AKS pull de imágenes
resource "azurerm_role_assignment" "acr_pull" {
  count                = var.aks_principal_id != null ? 1 : 0
  principal_id         = var.aks_principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.this.id
  skip_service_principal_aad_check = true
}
