terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.75.0"
    }
  }
}

provider "azurerm" {
  features {
    
  }
}

terraform {
    backend "azurerm" {
      resource_group_name = "terraform-backend-rg"
      storage_account_name = "sgaccountkhan10"
      container_name = "sgaccountkhan10container"
      key = "terraform.tfstate"
    }
}