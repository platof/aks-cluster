terraform {
  backend "azurerm" {
    resource_group_name   = "tfstate-training"
    storage_account_name  = "tfstatestoragetraining"
    container_name        = "tfstate"
    key                   = "infra-training.tfstate"
    use_azuread_auth      = true
  }
}