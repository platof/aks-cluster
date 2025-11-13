# 1. Bastion Host
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.80.250.0/26"]
}

resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = "bastion"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"

  ip_configuration {
    name                 = "bastion-ip"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  ip_connect_enabled     = true
  copy_paste_enabled     = true
  shareable_link_enabled = false
  tunneling_enabled      = true
}

# 2. Jumpbox VM
resource "azurerm_subnet" "mgmt" {
  name                 = "snet-mgmt"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.80.200.0/24"]
}

resource "azurerm_network_security_group" "mgmt" {
  name                = "nsg-mgmt"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-SSH-From-Bastion"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = azurerm_subnet.bastion.address_prefixes[0]
    destination_address_prefix = "*"
  }

  tags = var.tags

}

resource "azurerm_subnet_network_security_group_association" "mgmt" {
  subnet_id                 = azurerm_subnet.mgmt.id
  network_security_group_id = azurerm_network_security_group.mgmt.id

}

resource "azurerm_network_interface" "Jumpbox-nic" {
  name                = "jumpbox-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mgmt.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                            = "vm-jumpbox"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = "Standard_B1s"
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.Jumpbox-nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.jumpbox_ssh_public_key
  }

  identity { type = "SystemAssigned" }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(<<-CLOUDINIT
                #cloud-config
                package_update: true
                packages:
                  - azure-cli
                  - kubectl
                  - jq
                  - ca-certificates
                  - apt-transport-https
                  - gnupg
                  - lsb-release
                  - curl
                runcmd:
                  - apt-get update -y
                  - apt-get install -y azure-cli
                  - curl -sSLo /usr/local/bin/kubectl https://dl.k8s.io/release/$(curl -sSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
                  - chmod +x /usr/local/bin/kubectl
                  - az login --identity
                  - mkdir -p /home/${var.admin_username}/.kube
                  - chown -R ${var.admin_username}:${var.admin_username} /home/${var.admin_username}/.kube
                  - KUBECONFIG=/home/${var.admin_username}/.kube/config az aks get-credentials \
                    --resource-group ${var.resource_group_name} \
                    --name aks-${var.name} --overwrite-existing
                  - chown ${var.admin_username}:${var.admin_username} /home/${var.admin_username}/.kube/config
                CLOUDINIT
  )

}