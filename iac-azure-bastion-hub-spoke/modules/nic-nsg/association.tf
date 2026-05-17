resource "azurerm_network_interface_security_group_association" "this" {
  for_each = local.create_nsgs

  network_interface_id      = each.value.nic_id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}
