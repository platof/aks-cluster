# Static PIP for traefik ingress controller in the AKS node RG
resource "azurerm_public_ip" "ingress_pip" {
  name                = "ingress-pip"
  location            = var.location
  resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}
