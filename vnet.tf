resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}
# Resource: Create Virtual Network 1
resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet1"
  address_space        = ["10.5.0.0/16"]
  location            = "East US"
  resource_group_name = azurerm_resource_group.rg.name
}

# Resource: Create Virtual Network 2
resource "azurerm_virtual_network" "vnet2" {
  name                = "vnet2"
  address_space        = ["10.15.0.0/16"]
  location            = "East US"
  resource_group_name = azurerm_resource_group.rg.name
}

# Resource: Create Virtual Network Peering
resource "azurerm_virtual_network_peering" "vnet1_to_vnet2" {
  name                       = "vnet1-to-vnet2"
  resource_group_name        = azurerm_resource_group.rg.name
  virtual_network_name       = azurerm_virtual_network.vnet1.name
  remote_virtual_network_id  = azurerm_virtual_network.vnet2.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "vnet2_to_vnet1" {
  name                       = "vnet2-to-vnet1"
  resource_group_name        = azurerm_resource_group.rg.name
  virtual_network_name       = azurerm_virtual_network.vnet2.name
  remote_virtual_network_id  = azurerm_virtual_network.vnet1.id
  allow_virtual_network_access = true
}

# Resource: Create Public IP for VM1
resource "azurerm_public_ip" "vm1_public_ip" {
  name                = "vm1-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Resource: Create Network Interface for VM1 (with public IP)
resource "azurerm_network_interface" "vm1_nic" {
  name                = "vm1-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vnet1_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm1_public_ip.id
  }
}

# Resource: Create Network Interface for VM2 (only private IP)
resource "azurerm_network_interface" "vm2_nic" {
  name                = "vm2-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vnet1_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_ip
  }
}

# Resource: Create VM1 (with Public IP)
resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "vm1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1ms"
  network_interface_ids = [
    azurerm_network_interface.vm1_nic.id,
  ]
  admin_username      = "azureuser"
  admin_ssh_key {
    public_key = file("/home/roshan/.ssh/id_rsa.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  tags = {
    environment = "dev"
  }
}

# Resource: Create VM2 (Private IP only)
resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "vm2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1ms"
  network_interface_ids = [
    azurerm_network_interface.vm2_nic.id,
  ]
  admin_username      = "azureuser"
  admin_ssh_key {
    public_key = file(/home/roshan/.ssh/id_rsa.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  tags = {
    environment = "dev"
  }
}

# Resource: Create Subnet in VNET 1
resource "azurerm_subnet" "vnet1_subnet" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.5.1.0/24"]
}

# Output the Public and Private IPs
output "vm1_public_ip" {
  value = azurerm_public_ip.vm1_public_ip.ip_address
}

output "vm2_private_ip" {
  value = var.private_ip
}
