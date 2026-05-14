# Azure Bastion Hub with Dynamic VNet Peering (Terraform)

## Overview

This project implements a centralized access architecture in Microsoft Azure using Terraform.

It deploys a Hub virtual network with Azure Bastion and dynamically peers it with multiple **existing VNets (spokes)**.

Spoke VNets are defined using a **map of objects**, and Terraform retrieves their actual properties (such as location and ID) directly from Azure using data sources. This ensures consistency and avoids configuration drift.

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

* Created per spoke
* Allows only:

  * SSH (22)
  * RDP (3389)
* Source is restricted to the **Bastion subnet CIDR**

---

## Key Design Decisions

### 1. Map-Based Spoke Definition

Spokes are defined as a map:

```hcl
spokes = {
  spoke1 = {
    name                = "jodur-vnet"
    resource_group_name = "jodur-rg"
    location            = "southeastasia"
  }
}
```

* `each.key` → logical identifier (`spoke1`)
* `each.value.name` → actual Azure VNet name

---

### 2. Data Source Transformation

The data source uses the **VNet name as key**:

```hcl
data "azurerm_virtual_network" "spokes" {
  for_each = {
    for vnet in var.spokes : vnet.name => vnet
  }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}
```

---

### 3. Correct Resource Referencing

Because of the transformation, resources must reference spokes using:

```hcl
data.azurerm_virtual_network.spokes[each.value.name].id
```

---

### 4. Azure as Source of Truth

Even though `location` exists in variables, the implementation uses:

```hcl
data.azurerm_virtual_network.spokes[each.value.name].location
```

This ensures:

* Accuracy
* No drift between Terraform and Azure
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
* Spoke → VM (private IP)

---

## Features

* Centralized Azure Bastion deployment
* Dynamic VNet peering using `for_each`
* Map-based scalable configuration
* Data-driven lookup of existing VNets
* No public IPs on virtual machines
* NSG enforcing Bastion-only access
* Modular Terraform design

---

## Use Cases

* Secure remote access without exposing VMs
* Multi-VNet enterprise environments
* Centralized access for Dev / QA / Prod
* Cost optimization using single Bastion
* Integration with existing Azure VNets

---

## Project Structure

```
azure-bastion-hub-spoke/
│
├── main.tf
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

## Environment Folder (`env/`)

The `env` directory is used to separate configurations per environment (e.g., `dev`, `prod`, `test`).

### Example: `env/dev/`

* `backend.hcl`

  * Defines remote state configuration (Storage Account, container, key)
* `terraform.tfvars`

  * Contains environment-specific values such as:

    * application name
    * location
    * spoke VNets

This structure allows you to:

* Isolate environments cleanly
* Use different backends per environment
* Avoid hardcoding values in Terraform files

---

## Inputs

### Example: `env/dev/terraform.tfvars`

```hcl
application_name = "jodur-bastion"
primary_location = "southeastasia"

spokes = {
  spoke1 = {
    name                = "jodur-vnet"
    resource_group_name = "jodur-rg"
    location            = "southeastasia"
  }
}
```

---

## Backend Configuration

### Example: `env/dev/backend.hcl`

```hcl
resource_group_name  = "rg-tfstate"
storage_account_name = "tfstatehubspoke123"
container_name       = "tfstate"
key                  = "bastion-hub-spoke-dev.tfstate"
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

### 2. Discover Existing VNets

Terraform queries Azure using:

```hcl
data "azurerm_virtual_network"
```

This ensures correct:

* Resource IDs
* Locations

---

### 3. Create Dynamic Peering

For each spoke:

* Hub → Spoke peering
* Spoke → Hub peering

---

### 4. Apply Network Security Groups

* One NSG per spoke
* Allows:

  * Port 22 (SSH)
  * Port 3389 (RDP)
* Source:

  * Bastion subnet CIDR

> Note: NSG is created but subnet association is not included in this configuration.

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
* NSG restricts inbound traffic
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

* NSG subnet association
* Azure Firewall integration
* Private DNS zones
* Azure Monitor integration
* CI/CD pipeline
* RBAC enhancements

---

## Summary

This project demonstrates:

* Hub-and-Spoke architecture
* Dynamic Terraform design using maps and `for_each`
* Secure Bastion-based access
* Environment-based configuration management

It reflects real-world scenarios where existing VNets must be securely connected without being re-created.
