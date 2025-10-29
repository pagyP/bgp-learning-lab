# Simple Azure BGP Lab with VNet Peering and FRRouting VMs

variable "location" {
  default = "uksouth"
}

variable "vm_admin_password" {
  description = "Password for VM admin user."
  type        = string
}

resource "azurerm_resource_group" "bgp_lab" {
  name     = "bgp-lab-rg"
  location = var.location
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "bgp-vnet1"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.bgp_lab.name
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.bgp_lab.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_virtual_network" "vnet2" {
  name                = "bgp-vnet2"
  address_space       = ["10.2.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.bgp_lab.name
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.bgp_lab.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["10.2.0.0/24"]
}

resource "azurerm_virtual_network_peering" "vnet1_to_vnet2" {
  name                         = "vnet1-to-vnet2"
  resource_group_name          = azurerm_resource_group.bgp_lab.name
  virtual_network_name         = azurerm_virtual_network.vnet1.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet2.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "vnet2_to_vnet1" {
  name                         = "vnet2-to-vnet1"
  resource_group_name          = azurerm_resource_group.bgp_lab.name
  virtual_network_name         = azurerm_virtual_network.vnet2.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet1.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}

resource "azurerm_network_interface" "nic1" {
  name                = "bgp-nic1"
  location            = var.location
  resource_group_name = azurerm_resource_group.bgp_lab.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic2" {
  name                = "bgp-nic2"
  location            = var.location
  resource_group_name = azurerm_resource_group.bgp_lab.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm1" {
  name                            = "bgp-vm1"
  resource_group_name             = azurerm_resource_group.bgp_lab.name
  location                        = var.location
  size                            = "Standard_B1s"
  admin_username                  = "bgpuser"
  admin_password                  = var.vm_admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.nic1.id]
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
  # No cloud-init: students will install and configure FRR manually
}

resource "azurerm_linux_virtual_machine" "vm2" {
  name                            = "bgp-vm2"
  resource_group_name             = azurerm_resource_group.bgp_lab.name
  location                        = var.location
  size                            = "Standard_B1s"
  admin_username                  = "bgpuser"
  admin_password                  = var.vm_admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.nic2.id]
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
  # No cloud-init: students will install and configure FRR manually
}

output "vm1_private_ip" {
  value = azurerm_network_interface.nic1.private_ip_address
}

output "vm2_private_ip" {
  value = azurerm_network_interface.nic2.private_ip_address
}
