# Terragrunt 

## Example of modularization using Terragrunt

```shell
.
├── terragrunt-blueprints
│   └── network
├── terragrunt-environments
│   └── Account
│       └── us-east-1
│           └── dev
│               └── sandbox_network
└── terragrunt-modules
    ├── terraform-module-ec2
    │   └── examples
    │       └── basic
    └── terraform-module-vpc
        └── examples
            ├── custom-subnet-names-and-azs
            └── simple-vpc
```