output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "primary_subnet_id" {
  description = "ID of the primary subnet"
  value       = azurerm_subnet.primary.id
}

output "bastion_subnet_id" {
  description = "ID of the Bastion subnet"
  value       = try(azurerm_subnet.bastion[0].id, null)
}
