resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

# First Virtual Network (vnet1) (already defined earlier)
resource "azurerm_virtual_network" "vnet1" {
  name                = var.vnet_name_1
  resource_group_name = var.rg_name
  address_space       = var.address_space_1
  location            = var.location

  depends_on = [azurerm_resource_group.rg]
}

# Second Virtual Network (vnet2) for VM2
resource "azurerm_virtual_network" "vnet2" {
  name                = var.vnet_name_2
  resource_group_name = var.rg_name
  address_space       = var.address_space_2
  location            = var.location

  depends_on = [azurerm_resource_group.rg]
}

# Subnet for VM2 in vnet2
resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["10.15.0.0/24"]
}

# Network Interface for VM2 (only Private IP)
resource "azurerm_network_interface" "vm2_nic" {
  name                = "vm2-nic"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                    = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Virtual Machine (VM2) in vnet2 (Private IP only)
resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "vm2"
  resource_group_name = var.rg_name
  location            = var.location
  size                = "Standard_B1s"  # Choose a size for your VM
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.vm2_nic.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
 
}

  # OS and image for VM
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

  tags = {
    environment = "dev"
  }
}

# Output the Private IP of VM2
output "vm2_private_ip" {
  value = azurerm_network_interface.vm2_nic.ip_configuration[0].private_ip_address
}

