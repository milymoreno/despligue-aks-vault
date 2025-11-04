output "id" {
  description = "ID del cluster AKS"
  value       = azurerm_kubernetes_cluster.this.id
}

output "name" {
  description = "Nombre del cluster AKS"
  value       = azurerm_kubernetes_cluster.this.name
}

output "kube_config" {
  description = "Configuración de Kubernetes"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "kube_config_parsed" {
  description = "Configuración de Kubernetes parseada"
  value       = azurerm_kubernetes_cluster.this.kube_config
  sensitive   = true
}

output "cluster_fqdn" {
  description = "FQDN del cluster"
  value       = azurerm_kubernetes_cluster.this.fqdn
}

output "kubelet_identity" {
  description = "Identidad del kubelet"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity
}

output "principal_id" {
  description = "Principal ID de la identidad del cluster"
  value       = azurerm_kubernetes_cluster.this.identity[0].principal_id
}

output "node_resource_group" {
  description = "Nombre del Resource Group de los nodos"
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}
