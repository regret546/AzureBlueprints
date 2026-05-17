resource "azurerm_network_security_rule" "allow_bastion_to_vm" {
  for_each = var.vm_nics

  name      = "Allow-Bastion-To-VM"
  priority  = 100
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range       = "*"
  destination_port_ranges = var.allowed_ports

  source_address_prefix      = var.bastion_subnet_cidr
  destination_address_prefix = "*"

  resource_group_name         = split("/", local.effective_nsg_ids[each.key])[4]
  network_security_group_name = split("/", local.effective_nsg_ids[each.key])[8]
}
