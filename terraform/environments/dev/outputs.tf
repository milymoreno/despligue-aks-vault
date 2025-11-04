# ==========================================
# RESOURCE GROUP OUTPUTS
# ==========================================

output "resource_group_name" {
  description = "Nombre del Resource Group"
  value       = module.resource_group.name
}

output "resource_group_location" {
  description = "Ubicación del Resource Group"
  value       = module.resource_group.location
}

# ==========================================
# ACR OUTPUTS
# ==========================================

output "acr_name" {
  description = "Nombre del Azure Container Registry"
  value       = module.acr.name
}

output "acr_login_server" {
  description = "URL del servidor de login del ACR"
  value       = module.acr.login_server
}

output "acr_id" {
  description = "ID del ACR"
  value       = module.acr.id
}

# ==========================================
# AKS OUTPUTS
# ==========================================

output "aks_name" {
  description = "Nombre del cluster AKS"
  value       = module.aks.name
}

output "aks_id" {
  description = "ID del cluster AKS"
  value       = module.aks.id
}

output "aks_fqdn" {
  description = "FQDN del cluster AKS"
  value       = module.aks.cluster_fqdn
}

output "aks_node_resource_group" {
  description = "Resource Group de los nodos de AKS"
  value       = module.aks.node_resource_group
}

output "aks_kube_config" {
  description = "Configuración de kubectl para conectar al cluster"
  value       = module.aks.kube_config
  sensitive   = true
}

output "aks_principal_id" {
  description = "Principal ID de la identidad del cluster AKS"
  value       = module.aks.principal_id
}

output "aks_kubelet_identity" {
  description = "Identidad del kubelet"
  value       = module.aks.kubelet_identity
  sensitive   = true
}

# ==========================================
# KEY VAULT OUTPUTS
# ==========================================

output "key_vault_name" {
  description = "Nombre del Key Vault"
  value       = module.key_vault.name
}

output "key_vault_id" {
  description = "ID del Key Vault"
  value       = module.key_vault.id
}

output "key_vault_uri" {
  description = "URI del Key Vault"
  value       = module.key_vault.vault_uri
}

output "key_vault_secret_ids" {
  description = "IDs de los secretos creados"
  value       = module.key_vault.secret_ids
  sensitive   = true
}

# ==========================================
# COMANDOS ÚTILES
# ==========================================

output "commands" {
  description = "Comandos útiles para trabajar con la infraestructura"
  value = <<-EOT
  
  ╔════════════════════════════════════════════════════════════════╗
  ║           INFRAESTRUCTURA DESPLEGADA EXITOSAMENTE              ║
  ╚════════════════════════════════════════════════════════════════╝
  
  📦 Resource Group: ${module.resource_group.name}
  🐳 ACR: ${module.acr.login_server}
  ☸️  AKS: ${module.aks.name}
  🔐 Key Vault: ${module.key_vault.name}
  
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📋 COMANDOS ÚTILES
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  # Conectar a AKS:
  az aks get-credentials --resource-group ${module.resource_group.name} --name ${module.aks.name}
  
  # Verificar nodos:
  kubectl get nodes
  
  # Login a ACR:
  az acr login --name ${module.acr.name}
  
  # Build y push de imagen:
  az acr build --registry ${module.acr.name} --image holamundo/hello:latest .
  
  # Ver secretos en Key Vault:
  az keyvault secret list --vault-name ${module.key_vault.name}
  
  # Obtener valor de secreto:
  az keyvault secret show --vault-name ${module.key_vault.name} --name hello-greeting --query value -o tsv
  
  # Desplegar aplicación:
  kubectl apply -f k8s/
  
  # Ver servicios:
  kubectl get svc
  
  EOT
}
