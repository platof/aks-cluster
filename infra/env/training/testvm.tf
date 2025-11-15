# test-vm.tf
# Simple VM to test if public IPs work in this subscription

resource "azurerm_public_ip" "test_vm_pip" {
  name                = "test-vm-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(var.tags, {
    Purpose = "Test subscription networking"
  })
}

resource "azurerm_network_interface" "test_vm_nic" {
  name                = "test-vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.aks.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test_vm_pip.id
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "test_vm" {
  name                = "test-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.test_vm_nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.jumpbox_ssh_public_key # Or use var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Install nginx on boot
  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
    
    # Create a test page
    echo "<h1>Test VM - Subscription Network Check</h1><p>If you see this, public IPs work in this subscription!</p>" > /var/www/html/index.html
  EOF
  )

  tags = merge(var.tags, {
    Purpose = "Test subscription networking"
  })
}

# Output the test VM public IP
output "test_vm_public_ip" {
  value       = azurerm_public_ip.test_vm_pip.ip_address
  description = "Test VM public IP - curl this to verify subscription allows public access"
}