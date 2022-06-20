locals {
  # VPC - existing or new?
  #  vpc_id = var.vpc_id == null ? module.vpc.vpc_id : var.vpc_id
  #  # if vpc_id is null, use public_subnet from vpc module Otherwise ask the user for public_subnet_ids in addition to vpc_id
  #  public_subnet_ids = coalescelist(module.vpc.public_subnets, var.public_subnet_ids, [""])
  #  # if vpc_id is null, use database_subnet_group from vpc module Otherwise ask the user for database_subnet_group in addition to vpc_id
  #  database_subnet_group = var.database_subnet_group == "" ? module.vpc.database_subnet_group : var.database_subnet_group
  # Default CIDR for the VPC to be created if vpc_id is not provided
  # cidr = "10.10.0.0/16"

  tags = merge(
    {
      CloudQuery = var.name
    },
    var.tags,
  )
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.1.1"

  prefix = [var.name]
}


###################
# Resource Group
###################
resource "azurerm_resource_group" "rg" {
  name     = module.naming.resource_group.name
  location = var.location
}

####################
## Network
####################
// TODO support existing Network
module "network" {
  source  = "Azure/network/azurerm"
  version = "~> 3.5.0"

  vnet_name = module.naming.virtual_network.name

  resource_group_name = azurerm_resource_group.rg.name
  address_space       = "10.10.0.0/16"
  subnet_prefixes     = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  subnet_names        = [
    "${module.naming.subnet.name}-1",
    "${module.naming.subnet.name}-2",
    "${module.naming.subnet.name}-3"
  ]

  subnet_service_endpoints = {
    ("${module.naming.subnet.name}-1") : ["Microsoft.Sql"],
  }

  tags = local.tags

  depends_on = [azurerm_resource_group.rg]
}


####################
## AKS
####################
module "aks" {
  source  = "Azure/aks/azurerm"
  version = "~> 4.16.0"

  resource_group_name = azurerm_resource_group.rg.name

  kubernetes_version   = "1.23.5"
  orchestrator_version = "1.23.5"

  prefix          = var.name
  cluster_name    = module.naming.kubernetes_cluster.name
  network_plugin  = "azure"
  vnet_subnet_id  = element(module.network.vnet_subnets, 0)
  os_disk_size_gb = var.node_disk_size_gb
  sku_tier        = "Paid"

  #  client_id = azuread_application.aks_cluster.id
  #  client_secret = random_string.aks_cluster_password.result

  #  rbac_aad_client_app_id
  #  rbac_aad_server_app_id
  #  rbac_aad_server_app_secret

  enable_log_analytics_workspace   = false
  enable_role_based_access_control = false
  #  rbac_aad_admin_group_object_ids  = [data.azuread_group.aks_cluster_admins.id]
  rbac_aad_managed                 = false // TODO support RBAC with AAD
  private_cluster_enabled          = true
  enable_http_application_routing  = false
  enable_azure_policy              = true
  enable_auto_scaling              = true
  enable_host_encryption           = var.enable_host_encryption

  agents_min_count = 1
  agents_max_count = 2
  agents_count     = null

  # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes.
  agents_max_pods           = 30
  agents_pool_name          = "exnodepool"
  agents_availability_zones = [1, 2, 3]
  agents_type               = "VirtualMachineScaleSets"

  agents_labels = {
    "nodepool" : "node-pool"
  }

  agents_tags = merge(
    {
      Agent = "node-pool-agent"
    },
    var.tags,
  )

  enable_ingress_application_gateway = false
  #  ingress_application_gateway_name        = "${module.naming.kubernetes_cluster.name}-agw"
  #  ingress_application_gateway_subnet_cidr = "10.10.1.0/24"

  #  network_policy                 = "azure"
  #  net_profile_dns_service_ip     = "10.0.0.10"
  #  net_profile_docker_bridge_cidr = "170.10.0.1/16"
  #  net_profile_service_cidr       = "10.0.0.0/16"

  depends_on = [azurerm_resource_group.rg, module.network]
}

####################
## Postgres
####################
resource "random_password" "postgresql" {
  length  = 14
  special = false
}

module "postgresql" {
  source = "github.com/Azure/terraform-azurerm-postgresql"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  server_name                  = module.naming.postgresql_server.name
  sku_name                     = var.postgres_sku_name
  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = false
  administrator_login          = "postgres"
  administrator_password       = random_password.postgresql.result
  server_version               = var.postgres_server_version
  ssl_enforcement_enabled      = true
  db_names                     = ["${module.naming.postgresql_database.name}-1"]
  db_charset                   = "UTF8"

  public_network_access_enabled = var.publicly_accessible

  // TODO support firewall rules
  #  firewall_rule_prefix = "firewall-"
  #  firewall_rules       = [
  #    { name = "test1", start_ip = "10.0.0.5", end_ip = "10.0.0.8" },
  #    { start_ip = "127.0.0.0", end_ip = "127.0.1.0" },
  #  ]

  vnet_rule_name_prefix = module.naming.postgresql_virtual_network_rule.name
  vnet_rules            = var.publicly_accessible ? [
    {
      name      = "${module.naming.subnet.name}-1",
      subnet_id = module.network.vnet_subnets[0]
    }
  ] : []

  postgresql_configurations = {
    backslash_quote = "on",
  }

  tags = local.tags

  depends_on = [azurerm_resource_group.rg, module.network]
}


####################
## Vault
####################
resource "azurerm_key_vault" "vault" {
  name                       = module.naming.key_vault.name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
      "List",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover",
      "List",
    ]
  }
}

resource "azurerm_key_vault_secret" "pg_dsn" {
  name         = "${module.naming.key_vault_secret.name}-pg-dsn"
  value        = "postgres://${module.postgresql.administrator_login}:${random_password.postgresql.result}@${module.postgresql.server_fqdn}/postgres"
  key_vault_id = azurerm_key_vault.vault.id
}
