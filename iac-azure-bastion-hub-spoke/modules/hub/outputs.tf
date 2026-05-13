output "vnet_name" {
  value = azurerm_virtual_network.hub_vnet.name
}

output "vnet_id" {
  value = azurerm_virtual_network.hub_vnet.id
}

output "bastion_subnet_prefix" {
  value = var.bastion_subnet_prefix
}
