# Azure Bastion Hub with Dynamic VNet Peering (Terraform)

## Overview

This project implements a centralized access architecture in Microsoft Azure using Terraform.

It deploys a Hub virtual network with Azure Bastion and dynamically peers it with multiple existing VNets (spokes).

The solution enables secure, private access to virtual machines across environments without exposing public IP addresses, while optimizing cost through a single, centralized Bastion deployment.

---

## Architecture

### Hub VNet
- Hosts Azure Bastion  
- Acts as the centralized access point  

### Spoke VNets (Existing)
- Application or environment VNets  
- Referenced dynamically via Terraform variables  

### VNet Peering
- Connects Hub to multiple spokes  
- Enables low-latency private connectivity  

### Network Security Groups (NSG)
- Applied to spoke subnets  
- Allows only Bastion-originated RDP/SSH access  

---

## Key Flow

### Connection Flow

1. User connects to Azure Portal  
2. Accesses VM via Azure Bastion  

### Traffic Path

- User → Bastion (public endpoint)  
- Bastion → Hub VNet  
- Hub → Spoke VNet (via peering)  
- Spoke → VM (private IP)  

---

## Features

- Centralized Azure Bastion deployment  
- Dynamic peering using `for_each`  
- No public IPs on virtual machines  
- NSG enforcing Bastion-only access  
- Environment-based structure (`env/dev`, `env/prod`)  
- Remote state via `backend.hcl`  
- Modular Terraform design  

---

## Use Cases

- Secure remote access without exposing VMs  
- Multi-VNet enterprise environments  
- Centralized access for Dev / QA / Prod  
- Cost optimization using single Bastion  
- Integration with existing Azure VNets  

---

## Project Structure

```
iac-azure-bastion-hub-spoke/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
│
├── modules/
│   └── hub/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── env/
│   ├── dev/
│   │   ├── backend.hcl
│   │   └── terraform.tfvars
│   ├── prod/
│   │   ├── backend.hcl
│   │   └── terraform.tfvars
```

---

## Inputs

### Example: `terraform.tfvars`

```hcl
location            = "East Asia"
resource_group_name = "rg-network-dev"

bastion_subnet_cidr = "10.0.0.0/26"

spokes = {
  spoke1 = {
    name                = "spoke1-vnet"
    resource_group_name = "rg-spoke1-dev"
    location            = "East Asia"
  },
  spoke2 = {
    name                = "spoke2-vnet"
    resource_group_name = "rg-spoke2-dev"
    location            = "East Asia"
  }
}
```

---

## Backend Configuration

### Example: `backend.hcl`

```hcl
resource_group_name  = "rg-tfstate"
storage_account_name = "tfstatehubspoke123"
container_name       = "tfstate"
key                  = "bastion-hub-spoke-dev.tfstate"
```

---

## Architecture Diagram

![Azure Bastion Hub Architecture](./images/architecture.png)

---

## How It Works

### 1. Deploy Hub and Bastion

Terraform provisions:

- Resource Group  
- Hub VNet  
- AzureBastionSubnet  
- Public IP  
- Azure Bastion  

---

### 2. Reference Existing VNets

Terraform uses variables to reference existing VNets instead of creating them.

---

### 3. Create Dynamic Peering

For each spoke:

- Hub → Spoke peering  
- Spoke → Hub peering  

---

### 4. Apply Network Security Groups

- NSG attached to spoke subnets  
- Allows only:
  - Port 22 (SSH)  
  - Port 3389 (RDP)  
  - Source: `AzureBastion`  
- Denies all other inbound traffic  

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

- No public IPs on VMs  
- Bastion is the only access entry point  
- NSG enforces least-privilege  
- Reduced attack surface  
- Zero Trust aligned  

---

## Cost Considerations

Azure Bastion is billed hourly.

### Optimization Strategy

- Single centralized Bastion  
- Shared across multiple VNets  

### Recommended Usage

- Production → Always on  
- Dev/Test → Deploy on demand  

---

## Future Improvements

- Azure Firewall  
- Private DNS zones  
- Azure Monitor integration  
- CI/CD pipeline  
- RBAC enhancements  

---

## Summary

This project demonstrates:

- Hub-and-Spoke architecture  
- Centralized Bastion access  
- NSG-based security control  
- Environment-based Terraform deployments  

It reflects real-world enterprise scenarios where existing infrastructure must be securely integrated.