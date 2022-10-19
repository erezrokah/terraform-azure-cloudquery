variable "name" {
  description = "Name to use on all resources created"
  type        = string
  default     = "cloudquery"
}

variable "tags" {
  description = "A map of tags to use on all resources"
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "The location to host resources"
  type        = string
}

# Helm

variable "install_helm_chart" {
  description = "Enable/Disable helm chart installation"
  type        = bool
  default     = true
}

variable "chart_version" {
  description = "The version of CloudQuery helm chart"
  type        = string
  default     = "1.0.14" # Do not change CloudQuery helm chart version as it is automatically updated by Workflow
}

variable "config_file" {
  description = "Path to the CloudQuery config.hcl"
  type        = string
  default     = ""
}

variable "chart_values" {
  description = "Variables to pass to the helm chart"
  type        = string
  default     = ""
}

# Postgres
variable "postgres_server_version" {
  description = "Version of Azure Postgres engine to use"
  type        = string
  default     = "11"
}

variable "postgres_sku_name" {
  description = "Postgresql sku name"
  type        = string
  default     = "GP_Gen5_2"
}

variable "postgres_publicly_accessible" {
  description = "Make Postgres publicly accessible (might be needed if you want to connect to it from Grafana or other tools)."
  type        = bool
  default     = false
}

variable "postgres_backup_retention_days" {
  description = "Retention days for backup"
  type        = number
  default     = 7
}

variable "postgres_firewall_rules" {
  description = "If Postgres is publicly accessible you will need to specified a firewall rule to allow connections"
  type = list(object({
    name     = string
    start_ip = string
    end_ip   = string
  }))
  default = []
}

# AKS
variable "kubernetes_version" {
  description = "Specify which Kubernetes release to use. The default used is the latest Kubernetes version available in the region"
  type        = string
  default     = "1.23.5"
}

variable "kubernetes_orchestrator_version" {
  description = "Specify which Kubernetes release to use for the orchestration layer. The default used is the latest Kubernetes version available in the region"
  type        = string
  default     = "1.23.5"
}

variable "kubernetes_node_disk_size_gb" {
  description = "Node disk size in gb."
  type        = number
  default     = 30
}

variable "kubernetes_enable_host_encryption" {
  description = "Enable Host Encryption for default node pool. Encryption at host feature must be enabled on the subscription: https://docs.microsoft.com/azure/virtual-machines/linux/disks-enable-host-based-encryption-cli"
  type        = bool
  default     = false
}

variable "kubernetes_sku_tier" {
  description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid"
  type        = string
  default     = "Free"
}

variable "kubernetes_private_cluster_enabled" {
  description = "If true cluster API server will be exposed only on internal IP address and available only in cluster vnet."
  type        = bool
  default     = false
}
