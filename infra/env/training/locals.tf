locals {
  vnet_name          = "vnet-${var.name}"
  aks_subnet_name    = "snet-aks-${var.name}"
  nat_gateway_name   = "ngw-${var.name}"
  nat_public_ip_name = "pip-nat-${var.name}"
}