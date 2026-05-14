# Azure Bastion Hub with Dynamic VNet Peering (Terraform)

## Overview

This project implements a centralized access architecture in Microsoft Azure using Terraform.

It deploys a Hub virtual network with Azure Bastion and dynamically peers it with multiple **existing VNets (spokes)**.

Spoke VNets and their subnets are defined using a **map of objects**, and Terraform dynamically transforms this structure using a `local.tf` file to enable **per-subnet resource creation**.

The solution enables secure, private access to virtual machines without exposing public IP addresses, while optimizing cost through a single, centralized Bastion deployment.

---

## Architecture

### Hub VNet

* Hosts Azure Bastion
* Acts as the centralized access point
* Deployed via reusable Terraform module

### Spoke VNets (Existing)

* Pre-existing VNets in Azure
* Defined via `spokes` variable
* Queried dynamically using Terraform data sources

### VNet Peering

* Fully dynamic using `for_each`
* Creates:

  * Hub → Spoke peering
  * Spoke → Hub peering

### Network Security Groups (NSG)

* Created **per subnet (not per VNet)**
* Attached directly to each subnet
* Allows only:

  * SSH (22)
  * RDP (3389)
* Source is restricted to the **Bastion subnet CIDR**

---

## Naming Convention

This project uses a **generic, Bastion-focused naming convention**:

```
<scope>-<environment>-<role>-<resource>
```

### Examples

| Resource       | Example                        |
| -------------- | ------------------------------ |
| Hub VNet       | `dev-hub-bastion-vnet`         |
| Spoke VNet     | `dev-spoke-access-vnet`        |
| Resource Group | `rg-dev-network`               |
| Subnet         | `snet-client`, `snet-workload` |
| NSG            | `nsg-dev-spoke-access-client`  |

### Notes

* `hub` → centralized Bastion layer
* `spoke` → workload VNets
* `access` / `bastion-target` → indicates Bastion usage
* `snet-*` → Azure subnet naming standard

---

## Key Design Decisions

### 1. Map-Based Spoke Definition

Spokes are defined as a map:

```hcl
spokes = {
  spoke_access = {
    name                = "dev-spoke-access-vnet"
    resource_group_name = "rg-dev-network"

    subnets = {
      client = {
        name = "snet-client"
      }
      workload = {
        name = "snet-workload"
      }
    }
  }
}
```

* `spoke_key` → logical identifier (`spoke_access`)
* `subnet_key` → logical identifier (`client`, `workload`)
* `name` → actual Azure resource name

---

### 2. Use of `local.tf` (Flatten Pattern)

A `local.tf` file is used to transform nested maps into a flat structure:

```hcl
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
```

This enables:

* Iteration at **subnet level**
* Clean `for_each` usage
* Consistent key mapping across resources

---

### 3. Consistent Key Usage (Critical)

All resources use aligned keys:

| Resource                       | Key Used                |
| ------------------------------ | ----------------------- |
| `var.spokes`                   | `spoke_key`             |
| `data.azurerm_virtual_network` | `spoke_key`             |
| `local.spoke_subnets`          | `spoke_key + subnet`    |
| NSG / Association              | `vnet_name-subnet_name` |

This prevents common Terraform errors such as:

```
Invalid index
```

---

### 4. Azure as Source of Truth

Instead of relying on input variables, the implementation uses:

```hcl
data.azurerm_virtual_network.spokes[spoke_key].location
```

This ensures:

* Accuracy
* No configuration drift
* Safer deployments

---

## Key Flow

### Connection Flow

1. User connects to Azure Portal
2. Accesses VM via Azure Bastion

### Traffic Path

* User → Bastion (public endpoint)
* Bastion → Hub VNet
* Hub → Spoke VNet (via peering)
* Spoke → Subnet (NSG enforced)
* Subnet → VM (private IP)

---

## Features

* Centralized Azure Bastion deployment
* Dynamic VNet peering using `for_each`
* Map-based scalable configuration
* Flattened subnet iteration using `local.tf`
* NSG per subnet with strict access rules
* Automatic NSG-to-subnet association
* No public IPs on virtual machines
* Modular Terraform design

---

## Project Structure

```
azure-bastion-hub-spoke/
│
├── main.tf
├── local.tf
├── data.tf
├── variables.tf
├── outputs.tf
├── provider.tf
│
├── env/
│   └── dev/
│       ├── backend.hcl
│       └── terraform.tfvars
│
├── modules/
│   └── hub/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
```

---

## Sample `local.tf`

```hcl
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
```

---

## Inputs

### Example: `env/dev/terraform.tfvars`

```hcl
application_name = "bastion-demo"
primary_location = "southeastasia"

spokes = {
  spoke_access = {
    name                = "dev-spoke-access-vnet"
    resource_group_name = "rg-dev-network"

    subnets = {
      client = {
        name = "snet-client"
      }
      workload = {
        name = "snet-workload"
      }
    }
  }
}
```

---

## How It Works

### 1. Deploy Hub and Bastion

Terraform provisions:

* Resource Group
* Hub VNet
* AzureBastionSubnet
* Public IP
* Azure Bastion

---

### 2. Discover Existing VNets and Subnets

Terraform queries Azure using:

```hcl
data "azurerm_virtual_network"
data "azurerm_subnet"
```

---

### 3. Create Dynamic Peering

For each spoke:

* Hub → Spoke peering
* Spoke → Hub peering

---

### 4. Create and Attach NSG per Subnet

* NSG is created for each subnet
* NSG is attached using:

```hcl
azurerm_subnet_network_security_group_association
```

---

## Deployment

### Initialize

```bash
terraform init -backend-config=env/dev/backend.hcl
```

### Plan

```bash
terraform plan -var-file=env/dev/terraform.tfvars
```

### Apply

```bash
terraform apply -var-file=env/dev/terraform.tfvars
```

### Destroy

```bash
terraform destroy -var-file=env/dev/terraform.tfvars
```

---

## Security Considerations

* No public IPs on VMs
* Bastion is the only entry point
* NSG restricts inbound traffic per subnet
* Reduced attack surface
* Supports Zero Trust architecture

---

## Cost Considerations

Azure Bastion is billed hourly.

### Optimization Strategy

* Single centralized Bastion
* Shared across multiple VNets

---

## Future Improvements

* Per-subnet custom NSG rules via tfvars
* Azure Firewall integration
* Private DNS zones
* Azure Monitor integration
* CI/CD pipeline
* RBAC enhancements

---

## Summary

This project demonstrates:

* Hub-and-Spoke architecture
* Advanced Terraform patterns using `flatten` and `for_each`
* Subnet-level security enforcement using NSG
* Secure Bastion-based access
* Environment-based configuration management

It reflects real-world scenarios where existing VNets must be securely connected and managed without re-creating infrastructure.
