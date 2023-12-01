resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  name     = random_pet.rg_name.id
  location = var.resource_group_location
}

resource "random_string" "azurerm_api_management_name" {
  length  = 13
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "azurerm_api_management" "api" {
  name                = "apiservice${random_string.azurerm_api_management_name.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_email     = var.publisher_email
  publisher_name      = var.publisher_name
  sku_name            = "${var.sku}_${var.sku_count}"
}

resource "azurerm_api_management_product" "petstorepdt" {
  product_id            = "demo-petstorepdt"
  resource_group_name   = azurerm_resource_group.example.name
  api_management_name   = azurerm_api_management.example.name
  display_name          = "Demo Product"
  subscription_required = true
  approval_required     = false
  published             = true
}


resource "azurerm_api_management_subscription" "petstoresub" {
  subscription_id       = "demo-petstoresub"
  resource_group_name   = azurerm_resource_group.example.name
  api_management_name   = azurerm_api_management.example.name
  product_id            = azurerm_api_management_product.petstorepdt.product_id
  display_name          = "Demo Subscription"
  primary_key           = "__demo_primary_key__"
  secondary_key         = "__demo_secondary_key__"
  state                 = "active"
}

resource "azurerm_api_management_api" "petstoreapi" {
  name                = "petstore-api"
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.api.name
  revision            = "1"
  display_name        = "Pet Store API"
  path                = "petstore"
  protocols           = ["https"]

  import {
    content_format = "swagger-link-json"
    content_value  = "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/examples/v2.0/json/petstore-expanded.json"
  }
}

resource "azurerm_api_management_product_api" "petstoreapi" {
  resource_group_name   = azurerm_resource_group.rg.name
  api_management_name   = azurerm_api_management.api.name
  product_id            = azurerm_api_management_product.petstorepdt.product_id
  api_id                = azurerm_api_management_api.petstoreapi.api_id
}