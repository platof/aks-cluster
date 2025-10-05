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