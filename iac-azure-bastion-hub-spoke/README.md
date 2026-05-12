# Azure Bastion Hub with Dynamic VNet Peering (Terraform)

## Overview

This project implements a centralized access architecture in Microsoft Azure using Terraform. It deploys a Hub virtual network with Azure Bastion and dynamically peers it with multiple existing VNets (spokes).

The goal is to provide secure, private access to virtual machines across environments without exposing public IP addresses, while optimizing cost by avoiding multiple Bastion deployments.

---

## Architecture

This solution follows a Hub-and-Spoke network design:

* **Hub VNet**

  * Hosts Azure Bastion
  * Acts as the centralized access point

* **Spoke VNets (Existing)**

  * Application or environment VNets
  * Discovered dynamically via Terraform input

* **VNet Peering**

  * Connects Hub to multiple spokes
  * Enables private connectivity

### Key Flow

1. User connects to Azure Portal
2. Accesses VM via Azure Bastion
3. Traffic flows:

   * User → Bastion (public endpoint)
   * Bastion → Hub VNet
   * Hub → Spoke VNet (via peering)
   * Spoke → VM (private IP)

---

## Features

* Centralized Azure Bastion deployment
* Dynamic peering to multiple existing VNets
* No public IP required for virtual machines
* Scalable design using `for_each`
* Infrastructure-as-Code using Terraform
* Optional Bastion deployment for cost optimization

---

## Use Cases

* Secure remote access without exposing VMs to the internet
* Organizations with multiple VNets across teams or environments
* Centralized access control for Dev, QA, and Production
* Cost optimization by reducing duplicate Bastion deployments
* Integration with existing Azure infrastructure

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
```

---

## Inputs

### Example: terraform.tfvars

```
application_name = "demo"
primary_location = "East US"

spokes = [
  {
    name                = "vnet-app1"
    resource_group_name = "rg-app1"
  },
  {
    name                = "vnet-app2"
    resource_group_name = "rg-app2"
  }
]
```
---

## Architecture

![Azure Bastion Hub Architecture](./images/architecture.png)

---

## How It Works

### 1. Deploy Hub and Bastion

Terraform provisions:

* Resource Group
* Hub VNet
* AzureBastionSubnet
* Public IP
* Azure Bastion

### 2. Discover Existing VNets

Uses Terraform data sources to reference VNets that were not created in this project.

### 3. Create Dynamic Peering

For each VNet defined in the input:

* Hub → Spoke peering
* Spoke → Hub peering

---

## Deployment

### Initialize

```
terraform init
```

### Plan

```
terraform plan
```

### Apply

```
terraform apply
```

### Destroy (optional)

```
terraform destroy
```

---

## Security Considerations

* No public IPs required on virtual machines
* Access is centralized through Azure Bastion
* Reduces attack surface
* Aligns with Zero Trust principles

---

## Cost Considerations

Azure Bastion is billed hourly regardless of usage.

This project supports:

* Centralized Bastion (reduce duplication)
* Optional deployment pattern (enable/disable when needed)

Recommended:

* Always-on for production
* On-demand for dev/test environments

---

## Future Improvements

* Network Security Groups (NSGs)
* Azure Firewall integration
* Private DNS zones
* Logging and monitoring (Azure Monitor)
* CI/CD pipeline for automated deployments

---

## Summary

This project demonstrates a scalable and secure approach to managing remote access in Azure by combining:

* Hub-and-Spoke architecture
* Centralized Bastion access
* Dynamic infrastructure integration

It is designed to reflect real-world enterprise scenarios where infrastructure already exists and needs to be securely integrated.
