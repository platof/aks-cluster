resource "azurerm_kubernetes_cluster" "aks" {
  name                      = "aks-${var.name}"
  location                  = var.location
  resource_group_name       = var.resource_group_name
  dns_prefix                = "aks-${var.name}"
  sku_tier                  = "Free"
  kubernetes_version        = var.k8s_version
  oidc_issuer_enabled       = true
  private_cluster_enabled   = true
  workload_identity_enabled = true
  node_resource_group       = var.node_resource_group

  default_node_pool {
    name                         = "system"
    type                         = "VirtualMachineScaleSets"
    node_count                   = var.node_count
    vm_size                      = var.vm_size
    vnet_subnet_id               = azurerm_subnet.aks.id
    only_critical_addons_enabled = true
    max_pods                     = 30
    temporary_name_for_rotation  = "sysrot01"
    upgrade_settings {
      max_surge = "33%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"


  }

  tags = {
    Environment = "training"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  name                        = "internal"
  kubernetes_cluster_id       = azurerm_kubernetes_cluster.aks.id
  mode                        = "User"
  vm_size                     = "Standard_D2s_v3"
  node_count                  = 1
  temporary_name_for_rotation = "userrot01"

}
