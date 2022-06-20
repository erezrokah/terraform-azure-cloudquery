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
  default     = "eastus"
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
  default     = "0.2.6"
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

variable "publicly_accessible" {
  description = "Make Postgres publicly accessible (might be needed if you want to connect to it from Grafana or other tools)."
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Retention days for backup"
  type        = number
  default     = 7
}


# AKS
variable "node_disk_size_gb" {
  description = "Node disk size in gb."
  type        = number
  default     = 30
}

variable "enable_host_encryption" {
  description = "Enable Host Encryption for default node pool. Encryption at host feature must be enabled on the subscription: https://docs.microsoft.com/azure/virtual-machines/linux/disks-enable-host-based-encryption-cli"
  type        = bool
  default     = false
}


#variable "allowed_cidr_blocks" {
#  description = "If RDS is publicly accessible it is highly advised to specify allowed cidrs from where you are planning to connect"
#  type        = list(string)
#  default     = []
#}

#variable "project_id" {
#  description = "The ID of the project in which resources will be provisioned."
#  type        = string
#}
#


#variable "zones" {
#  type        = list(string)
#  description = "The zone to host the cluster in (required if is a zonal cluster), by default will pick one of the zones in the region"
#  default     = []
#}
#
#variable "gke_version" {
#  type        = string
#  description = "Version` of GKE to use for the GitLab cluster"
#  default     = "1.21"
#}
#
#variable "machine_type" {
#  type        = string
#  description = "Machine type to use for the cluster"
#  default     = "n2-highcpu-4"
#}
#
#variable "authorized_networks" {
#  description = "If Cloud SQL accessible it is highly advised to specify allowed cidrs from where you are planning to connect"
#  type        = list(map(string))
#  default     = []
#  # For public use
#  # [{name = "public", value = "0.0.0.0/0"}]
#}
#
#
