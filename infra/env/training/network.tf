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

# Allow NodePort range from the Azure LB
#resource "azurerm_network_security_rule" "allow_nodeports_from_az_lb" {
#  name                        = "allow-aks-nodeports"
#  resource_group_name         = var.node_resource_group
#  network_security_group_name = var.node_nsg_name
#  priority                    = 401
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "Tcp"
#  source_port_range           = "*"
#  destination_port_ranges     = ["30000-32767"] # Traefik websecure nodePort
#  source_address_prefix       = "AzureLoadBalancer"
#  destination_address_prefix  = "*"
#}

#resource "azurerm_network_security_rule" "allow_kube_proxy_probe" {
#  name                        = "allow-aks-kube-proxy-probe"
#  resource_group_name         = var.node_resource_group
#  network_security_group_name = var.node_nsg_name
#  priority                    = 399
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "Tcp"
#  source_port_range           = "*"
#  source_address_prefix       = "AzureLoadBalancer"
#  destination_address_prefix  = "*"
#  destination_port_range      = "10256"
#}

#resource "azurerm_network_security_rule" "allow_office_to_aks" {
#  name                        = "allow-office-to-aks"
#  resource_group_name         = var.node_resource_group
#  network_security_group_name = var.node_nsg_name
#  priority                    = 101
#  direction                   = "Inbound"
#  access                      = "Allow"
# protocol                    = "Tcp"
#  source_port_range           = "*"
#  destination_port_ranges     = ["80", "443"]
#  source_address_prefix       = "195.2.160.150/32" # office IP range
# destination_address_prefix  = "*"
#}

# Temporary rule to allow all Internet traffic for debugging
#resource "azurerm_network_security_rule" "temp_allow_all_internet" {
#  name                        = "temp-allow-all-internet"
#  resource_group_name         = var.node_resource_group
# network_security_group_name = var.node_nsg_name
#  priority                    = 100
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "Tcp"
#  source_port_range           = "*"
#  destination_port_ranges     = ["80", "443"]
#  source_address_prefix       = "Internet"
#  destination_address_prefix  = "*"
#}
