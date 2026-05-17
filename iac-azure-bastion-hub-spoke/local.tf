locals {
  spoke_subnets = flatten([
    for spoke_key, spoke in var.spokes : [
      for subnet_key, subnet in spoke.subnets : {
        spoke_key      = spoke_key
        subnet_key     = subnet_key
        vnet_name      = spoke.name
        resource_group = spoke.resource_group_name
        subnet_name    = subnet.name
      }
    ]
  ])
}
