# Hub -> Spoke peering
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "hub-to-${var.spoke_name}"
  resource_group_name       = var.hub_resource_group_name
  virtual_network_name      = var.hub_virtual_network_name
  remote_virtual_network_id = var.spoke_remote_virtual_network_id
}

# Spoke -> Hub peering
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "${var.spoke_name}-to-hub"
  resource_group_name       = var.spoke_resource_group_name
  virtual_network_name      = var.spoke_virtual_network_name
  remote_virtual_network_id = var.hub_remote_virtual_network_id
}
