# Postgres
output "postgres_fqdn" {
  description = "Fqdn of the Postgres server"
  value       = module.postgresql.server_fqdn
}

output "postgres_server_administrator_password" {
  description = "Administrator password for cloudquery database"
  value       = module.postgresql.administrator_password
  sensitive   = true
}

# Network
output "network_id" {
  description = "ID of the network that was created"
  value       = module.network.vnet_id
}

# AKS
output "aks_host" {
  description = "AKS host"
  value       = module.aks.host
}
