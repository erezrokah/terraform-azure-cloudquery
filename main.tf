locals {
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
  version = "~> 0.2.0"

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
module "network" {
  source  = "Azure/network/azurerm"
  version = "~> 5.3.0"

  vnet_name = module.naming.virtual_network.name

  resource_group_name = azurerm_resource_group.rg.name
  address_space       = "10.10.0.0/16"
  subnet_prefixes     = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  subnet_names = [
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
  source = "github.com/Azure/terraform-azurerm-aks?ref=6.2.0"

  resource_group_name = azurerm_resource_group.rg.name

  kubernetes_version   = var.kubernetes_version
  orchestrator_version = var.kubernetes_orchestrator_version

  prefix          = var.name
  cluster_name    = module.naming.kubernetes_cluster.name
  network_plugin  = "azure"
  vnet_subnet_id  = element(module.network.vnet_subnets, 0)
  os_disk_size_gb = var.kubernetes_node_disk_size_gb
  sku_tier        = var.kubernetes_sku_tier

  rbac_aad_managed = false

  log_analytics_workspace_enabled   = false
  role_based_access_control_enabled = false

  private_cluster_enabled          = var.kubernetes_private_cluster_enabled
  http_application_routing_enabled = true
  azure_policy_enabled             = true
  enable_auto_scaling              = true
  enable_host_encryption           = var.kubernetes_enable_host_encryption

  agents_min_count = 1
  agents_max_count = 2
  agents_count     = null

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

  tags = local.tags

  ingress_application_gateway_enabled = false
  network_policy                      = "azure"

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
  source = "github.com/Azure/terraform-azurerm-postgresql?ref=0f607dbc9d08528bb16a48fc9dc8831aa4a92f5c"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  server_name                  = module.naming.postgresql_server.name
  sku_name                     = var.postgres_sku_name
  backup_retention_days        = var.postgres_backup_retention_days
  geo_redundant_backup_enabled = false
  administrator_login          = "postgres"
  administrator_password       = azurerm_key_vault_secret.pg_password.value
  server_version               = var.postgres_server_version
  ssl_enforcement_enabled      = true
  db_names                     = ["${module.naming.postgresql_database.name}-1"]
  db_charset                   = "UTF8"

  public_network_access_enabled = var.postgres_publicly_accessible

  firewall_rule_prefix = module.naming.postgresql_firewall_rule.name
  firewall_rules       = var.postgres_firewall_rules

  vnet_rule_name_prefix = module.naming.postgresql_virtual_network_rule.name
  vnet_rules = var.postgres_publicly_accessible ? [
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

resource "azurerm_private_endpoint" "psql_private_endpoint" {
  count               = var.postgres_publicly_accessible == true ? 0 : 1
  name                = "${module.naming.private_endpoint.name}-psql"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.network.vnet_subnets[0]

  private_service_connection {
    name                           = "${module.naming.private_endpoint.name}-privateserviceconnection"
    private_connection_resource_id = module.postgresql.server_id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }
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

resource "azurerm_key_vault_secret" "pg_password" {
  name         = "${module.naming.key_vault_secret.name}-pg-password"
  value        = random_password.postgresql.result
  key_vault_id = azurerm_key_vault.vault.id
}

resource "azurerm_key_vault_secret" "pg_dsn" {
  name         = "${module.naming.key_vault_secret.name}-pg-dsn"
  value        = "postgresql://${module.postgresql.server_fqdn}:5432/${module.naming.postgresql_database.name}-1?user=${module.postgresql.administrator_login}@${module.postgresql.server_name}&password=${random_password.postgresql.result}&sslmode=require"
  key_vault_id = azurerm_key_vault.vault.id
}
