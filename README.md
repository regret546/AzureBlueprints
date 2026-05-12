# AzureBlueprints

A collection of Infrastructure-as-Code (IaC) blueprints for Microsoft Azure, focused on practical and scalable cloud solutions.

This repository demonstrates real-world implementations of Azure architecture using Terraform, with an emphasis on networking, security, and cost-aware design.

## Projects

### Bastion Hub & Spoke

**Path:** `iac-azure-bastion-hub-spoke/`

A hub-and-spoke network design with centralized Azure Bastion for secure VM access across multiple VNets.

* Centralized remote access without public IPs
* Scalable across multiple spoke VNets
* Designed with cost and operational efficiency in mind

See full details: `./iac-azure-bastion-hub-spoke/README.md`

## Structure

```id="k3kqtw"
AzureBlueprints/
├── iac-azure-bastion-hub-spoke/
└── README.md
```

## Technologies

* Terraform
* Microsoft Azure

## Notes

Each project folder includes its own documentation with architecture details and deployment steps.
