####################
## Helm Chart
####################
provider "helm" {
  kubernetes {
    host                   = module.aks.host
    client_certificate     = base64decode(module.aks.client_certificate)
    client_key             = base64decode(module.aks.client_key)
    cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
  }
}

resource "helm_release" "cloudquery" {
  for_each         = toset(var.install_helm_chart ? ["cloudquery"] : [])
  name             = var.name
  namespace        = "cloudquery"
  repository       = "https://cloudquery.github.io/helm-charts"
  chart            = "cloudquery"
  version          = var.chart_version
  create_namespace = true
  wait             = true
  values = [
    <<EOT
serviceAccount:
  enabled: true
  annotations:
    "azure.workload.identity/tenant-id": ${data.azurerm_client_config.current.tenant_id}
envRenderSecret:
  "CQ_VAR_DSN": "${azurerm_key_vault_secret.pg_dsn.value}"
config: |
  ${indent(2, file(var.config_file))}
EOT
  ,
    var.chart_values
  ]

  depends_on = [
    module.aks.cluster_id,
  ]
}
