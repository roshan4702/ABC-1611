terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.7.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "547278e7-01d9-4f7c-9e1d-b32e9dc1d729"
}


