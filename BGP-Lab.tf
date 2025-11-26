# Simple Azure BGP Lab with VNet Peering and FRRouting VMs

resource "azurerm_resource_group" "bgp_lab" {
  name     = "bgp-lab-rg-1"
  location = var.location
}

# Create VNets using module
module "vnets" {
  for_each = var.vnets

  source              = "./modules/vnet"
  vnet_name           = each.value.vnet_name
  address_space       = each.value.address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.bgp_lab.name
  primary_subnet_name = each.value.primary_subnet_name
  primary_subnet_prefix = each.value.primary_subnet_prefix
  create_bastion_subnet = each.value.create_bastion_subnet
  bastion_subnet_prefix = try(each.value.bastion_subnet_prefix, [])
}

resource "azurerm_virtual_network_peering" "peerings" {
  for_each = var.vnet_peerings

  name                         = each.value.name
  resource_group_name          = azurerm_resource_group.bgp_lab.name
  virtual_network_name         = module.vnets[each.value.source_vnet].vnet_name
  remote_virtual_network_id    = module.vnets[each.value.target_vnet].vnet_id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}

# Create VMs using module
module "vms" {
  for_each = var.vms

  source              = "./modules/vm"
  vm_name             = each.value.vm_name
  nic_name            = each.value.nic_name
  location            = var.location
  resource_group_name = azurerm_resource_group.bgp_lab.name
  vm_size             = each.value.vm_size
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  subnet_id           = module.vnets[each.value.vnet_key].primary_subnet_id
  image_offer         = "ubuntu-24_04-lts"
  image_sku           = "server"
}


// Optional Bastion.  VMs are Linux so serial console may suffice
/* resource "azurerm_bastion_host" "bastion" {
  name                = "bgp-bastion"
  location            = var.location
  resource_group_name = azurerm_resource_group.bgp_lab.name
  sku                 = "Basic"

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
  }
}

resource "azurerm_public_ip" "bastion_public_ip" {
  name                = "bgp-bastion-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.bgp_lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
*/

output "vm_ips" {
  value = { for name, vm in module.vms : name => vm.private_ip_address }
}
