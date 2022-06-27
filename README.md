# CloudQuery Azure Module

This folder contains a Terraform module to deploy a CloudQuery cluster in Azure on top of AKS.

## Usage

Examples are included in the example folder, but simple usage is as follows:

```hcl
module "cloudquery" {
  source  = "cloudquery/cloudquery/azure"
  version = "~> 0.5"

  name = "cloudquery"


  # path to your cloudquery config
  config_file = "config.hcl"

}
```

### Existing VPC

TDB

### Run Helm Seperately

TDB

## Examples

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

| Name                                                                      | Version  |
|---------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | > = 0.15 |
| <a name="requirement_azurerm"></a> [azure](#requirement\_azurerm)         | ~> 2.4.6 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm)                | ~> 2.11  |
| <a name="requirement_random"></a> [random](#requirement\_random)          | ~> 3.3   |

## Providers

| Name | Version  |
|------|----------|
| <a name="provider_azurerm"></a> [aws](#provider\_azurerm) | ~> 2.4.6 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.11  |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.3   |

## Modules

| Name                                                                             | Source | Version   |
|----------------------------------------------------------------------------------|--------|-----------|
| <a name="module_naming"></a> [naming](#module\_naming)                           | Azure/naming/azurerm | ~> 0.1.1  |
| <a name="module_network"></a> [network](#module\_network)                        | Azure/network/azurerm | ~> 3.5.0  |
| <a name="module_aks"></a> [eks](#module\_aks)                                    | Azure/aks/azurerm | ~> 4.16.0 |
| <a name="module_postgresql"></a> [postgresql](#module\_postgresql)               | Azure/postgresql/azurerm | ~> 2.1.0  |

## Resources

| Name | Type |
|------|------|

[//]: # (| [aws_db_parameter_group.cloudquery]&#40;https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group&#41; | resource |)


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|

[//]: # (| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks]&#40;#input\_allowed\_cidr\_blocks&#41; | If RDS is publicly accessible it is highly advised to specify allowed cidrs from where you are planning to connect | `list&#40;string&#41;` | `[]` | no |)


## Outputs

| Name | Description |
|------|-------------|

[//]: # (| <a name="output_irsa_arn"></a> [irsa\_arn]&#40;#output\_irsa\_arn&#41; | ARN of IRSA - &#40;IAM Role for service account&#41; |)


<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Troubleshooting

If helm installtion is stuck in some hanging state you can run the following commands:

```bash
# check if helm is installed in cloudquery namespace
helm ls -n cloudquery
# If yes uninstall with the your release name
helm uninstall YOUR_RELEASE_NAME -n cloudquery
```

## Authors

Module is maintained by [Anton Babenko](https://github.com/antonbabenko) and [CloudQuery Team](https://github.com/cloudquery/cloudquery).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/cloudquery/terraform-aws-cloudquery/tree/main/LICENSE) for full details.
