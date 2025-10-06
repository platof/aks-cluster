output "vnet_id" {
  description = "The ID of the Virtual Network."
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The name of the Virtual Network."
  value       = azurerm_virtual_network.vnet.name
}

output "aks_subnet_id" {
  description = "The ID of the AKS Subnet."
  value       = azurerm_subnet.aks.id
}

output "nat_public_ip_name" {
  description = "The name of the NAT Gateway Public IP (if created)."
  value       = var.create_nat_gateway ? azurerm_public_ip.nat[0].name : null
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "aks_resource_group" {
  value = azurerm_kubernetes_cluster.aks.resource_group_name
}

output "aks_kubelet_identity" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

output "aks_oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}

output "aks_api_server" {
  value = azurerm_kubernetes_cluster.aks.private_fqdn
}