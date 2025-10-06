# prod.tfvars
location            = "germanywestcentral"
resource_group_name = "aks-rg"
name                = "aks-training"
vnet_cidr           = "10.80.0.0/16"
aks_subnet_cidr     = "10.80.4.0/22"
node_count          = 1
vm_size             = "Standard_D4s_v3"
node_resource_group = "aks-nodes-rg"
k8s_version         = "1.34.1"