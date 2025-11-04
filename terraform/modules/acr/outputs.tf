output "id" {
  description = "ID del Azure Container Registry"
  value       = azurerm_container_registry.this.id
}

output "name" {
  description = "Nombre del ACR"
  value       = azurerm_container_registry.this.name
}

output "login_server" {
  description = "URL del servidor de login del ACR"
  value       = azurerm_container_registry.this.login_server
}

output "admin_username" {
  description = "Usuario admin del ACR (si está habilitado)"
  value       = var.admin_enabled ? azurerm_container_registry.this.admin_username : null
  sensitive   = true
}

output "admin_password" {
  description = "Password admin del ACR (si está habilitado)"
  value       = var.admin_enabled ? azurerm_container_registry.this.admin_password : null
  sensitive   = true
}

output "identity_principal_id" {
  description = "Principal ID de la identidad administrada del ACR"
  value       = var.identity_enabled ? azurerm_container_registry.this.identity[0].principal_id : null
}
