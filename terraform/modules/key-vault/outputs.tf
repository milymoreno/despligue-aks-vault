output "id" {
  description = "ID del Key Vault"
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "Nombre del Key Vault"
  value       = azurerm_key_vault.this.name
}

output "vault_uri" {
  description = "URI del Key Vault"
  value       = azurerm_key_vault.this.vault_uri
}

output "tenant_id" {
  description = "Tenant ID del Key Vault"
  value       = azurerm_key_vault.this.tenant_id
}

output "secret_ids" {
  description = "Map de IDs de secretos creados"
  value       = { for k, v in azurerm_key_vault_secret.secrets : k => v.id }
}

output "secret_versions" {
  description = "Map de versiones de secretos creados"
  value       = { for k, v in azurerm_key_vault_secret.secrets : k => v.version }
}
