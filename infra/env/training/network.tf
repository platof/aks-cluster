resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "aks" {
  name                 = local.aks_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.aks_subnet_cidr]

}

# NAT Gateway (for deterministic outbound) + Public IP
resource "azurerm_public_ip" "nat" {
  count               = var.create_nat_gateway ? 1 : 0
  name                = local.nat_public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "ngw" {
  count               = var.create_nat_gateway ? 1 : 0
  name                = local.nat_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "assoc" {
  count                = var.create_nat_gateway ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.ngw[0].id
  public_ip_address_id = azurerm_public_ip.nat[0].id
}

# Attach NAT GW to AKS subnet (drives outbound through this IP)
resource "azurerm_subnet_nat_gateway_association" "aks" {
  count          = var.create_nat_gateway ? 1 : 0
  subnet_id      = azurerm_subnet.aks.id
  nat_gateway_id = azurerm_nat_gateway.ngw[0].id
}