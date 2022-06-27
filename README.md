# CloudQuery Azure Module

This folder contains a Terraform module to deploy a CloudQuery cluster in Azure on top of AKS.

## Usage

Examples are included in the example folder, but simple usage is as follows:

```hcl
module "cloudquery" {
  source  = "cloudquery/cloudquery/azure"
  version = "~> 0.1"

  name = "cloudquery"


  # path to your cloudquery config
  config_file = "config.hcl"

}
```

### Existing VPC

TDB

### Run Helm Separately

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

| Name                                                          | Version  |
|---------------------------------------------------------------|----------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 2.4.6 |
| <a name="provider_helm"></a> [helm](#provider\_helm)          | ~> 2.11  |
| <a name="provider_random"></a> [random](#provider\_random)    | ~> 3.3   |

## Modules

| Name                                                                             | Source | Version   |
|----------------------------------------------------------------------------------|--------|-----------|
| <a name="module_naming"></a> [naming](#module\_naming)                           | Azure/naming/azurerm | ~> 0.1.1  |
| <a name="module_network"></a> [network](#module\_network)                        | Azure/network/azurerm | ~> 3.5.0  |
| <a name="module_postgresql"></a> [postgresql](#module\_postgresql)               | Azure/postgresql/azurerm | ~> 2.1.0  |

## Resources

| Name | Type |
|------|------|

[//]: # (| [aws_db_parameter_group.cloudquery]&#40;https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group&#41; | resource |)


## Inputs

| Name                                           | Description | Type     | Default   | Required |
|------------------------------------------------|-------------|----------|-----------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The location to host resources | `string` |  |   yes    |
| <a name="input_name"></a> [name](#input\_name) | Name to use on all resources created | `string` | `cloudquery` |    no    |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to use on all resources | `map(string)` | `{}`      |    no    |
| <a name="input_install_helm_chart"></a> [install\_helm\_chart](#input\_install\_helm\_chart) | Enable/Disable helm chart installation | `bool` | `true` | no |
| <a name="input_chart_values"></a> [chart\_values](#input\_chart\_values) | Variables to pass to the helm chart | `string` | `""` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | The version of CloudQuery helm chart | `string` | `"0.2.6"` | no |
| <a name="input_config_file"></a> [config\_file](#input\_config\_file) | Path to the CloudQuery config.hcl | `string` | `""` | no |
| <a name="input_postgres_server_version"></a> [postgres\_server\_version](#input\_postgres\_server\_version) | Version of Azure Postgres engine to use | `string` | `11` |    no    |
| <a name="input_postgres_sku_name"></a> [postgres\_sku\_name](#input\_postgres\_sku\_name) | Postgresql sku name | `string` | `GP_Gen5_2` |    no    |
| <a name="input_postgres_publicly_accessible"></a> [postgres\_publicly\_accessible](#input\_postgres\_publicly\_accessible) | Make Postgres publicly accessible (might be needed if you want to connect to it from Grafana or other tools). | `bool` | `true` |    no    |
| <a name="input_postgres_backup_retention_days"></a> [postgres\_backup\_retention_days](#input\_postgres\_backup\_retention_days) | Retention days for backup | `number` | `7` |    no    |
| <a name="input_postgres_firewall_rules"></a> [postgres\_firewall\_rules](#input\_postgres\_firewall\_rules) | If Postgres is publicly accessible you will need to specified a firewall rule to allow connections | ```list(object({name     = string start_ip = string end_ip   = string}))``` | `[]` |    no    |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Specify which Kubernetes release to use. The default used is the latest Kubernetes version available in the region | `string` | `1.23.5` |    no    |
| <a name="input_kubernetes_orchestrator_version"></a> [kubernetes\_orchestrator\_version](#input\_kubernetes\_orchestrator\_version) | Specify which Kubernetes release to use for the orchestration layer. The default used is the latest Kubernetes version available in the region | `string` | `1.23.5` |    no    |
| <a name="input_kubernetes_node_disk_size_gb"></a> [kubernetes\_node\_disk\_size\_gb](#input\_kubernetes\_node\_disk\_size\_gb) | Node disk size in gb. | `number` | `30` |    no    |
| <a name="input_kubernetes_enable_host_encryption"></a> [kubernetes\_enable\_host\_encryption](#input\_kubernetes\_enable\_host\_encryption) | Enable Host Encryption for default node pool. Encryption at host feature must be enabled on the subscription: https://docs.microsoft.com/azure/virtual-machines/linux/disks-enable-host-based-encryption-cli | `bool` | `false` |    no    |
| <a name="input_kubernetes_sku_tier"></a> [kubernetes\_sku\_tier](#input\_kubernetes\_sku\_tier) | The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid | `string` | `cloudquery` |    no    |
| <a name="input_kubernetes_private_cluster_enabled"></a> [kubernetes\_private\_cluster\_enabled](#input\_kubernetes\_private\_cluster\_enabled) | If true cluster API server will be exposed only on internal IP address and available only in cluster vnet. | `bool` | `false` |    no    |


## Outputs

| Name                                                                                                                                                        | Description |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| <a name="output_postgres_fqdn"></a> [postgres\_fqdn](#output\_postgres\_fqdn)                                                                               | Fqdn of the Postgres server |
| <a name="output_postgres_server_administrator_password"></a> [postgres\_server_administrator\_password](#output\_postgres\_server\_administrator\_password) | Administrator password for cloudquery database |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id)                                                                                        | ID of the network that was created |
| <a name="output_aks_host"></a> [aks\_host](#output\_aks\_host)                                                                                              | AKS host |

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

Module is maintained by  [CloudQuery Team](https://github.com/cloudquery/cloudquery).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/cloudquery/terraform-azure-cloudquery/tree/main/LICENSE) for full details.
