resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks-${var.name}"

  sku_tier = "Free"

  kubernetes_version = var.k8s_version

  oidc_issuer_enabled = true
  workload_identity_enabled = true
  node_resource_group = var.node_resource_group

  default_node_pool {
    name       = "system"
    type = "VirtualMachineScaleSets"
    node_count = var.node_count
    vm_size    = var.vm_size
    vnet_subnet_id = azurerm_subnet.aks.id
    only_critical_addons_enabled = true
    max_pods = 30
    upgrade_settings {
        max_surge = "33%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_plugin_mode = "overlay"
    network_data_plane   = "cilium"
    network_policy = "cilium"
    load_balancer_sku = "standard"
    outbound_type    = "userAssignedNATGateway"
  }

  tags = {
    Environment = "training"
  }
}

