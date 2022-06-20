provider "azurerm" {
  features {}
}

##############################################################
# CloudQuery
##############################################################

module "cloudquery" {
  source = "../../"

  # Name to use on all resources created
  name = "cq-complete-ex"
  location = "East US"

  config_file = "config.hcl"
  #  publicly_accessible = true
  #  install_helm_chart = false


  tags = {
    "Name" = "cq-complete-ex"
  }
}
