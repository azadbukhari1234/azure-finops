# Storage account required for Azure Functions internal operations
resource "azurerm_storage_account" "func_sa" {
  name                     = "${var.prefix}funcstore${var.environment}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = var.environment
    Project     = "Serverless FinOps"
  }
}

# App Service Plan for Azure Functions (Consumption / Serverless Plan)
resource "azurerm_service_plan" "func_plan" {
  name                = "${var.prefix}-func-plan-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1" # Consumption tier (Serverless)

  tags = {
    Environment = var.environment
    Project     = "Serverless FinOps"
  }
}

# Azure Function App (HTTP Triggered)
resource "azurerm_linux_function_app" "func" {
  name                        = "${var.prefix}-func-${var.environment}"
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  storage_account_name        = azurerm_storage_account.func_sa.name
  storage_account_access_key  = azurerm_storage_account.func_sa.primary_access_key
  service_plan_id             = azurerm_service_plan.func_plan.id

  site_config {
    application_stack {
      python_version = "3.11" # You can use Python for your serverless function code
    }
  }

  app_settings = {
    "COSMOS_DB_ENDPOINT" = azurerm_cosmosdb_account.cosmos.endpoint
    "COSMOS_DB_KEY"      = azurerm_cosmosdb_account.cosmos.primary_key
    "COSMOS_DB_NAME"     = azurerm_cosmosdb_sql_database.db.name
    "COSMOS_CONTAINER"   = azurerm_cosmosdb_sql_container.container.name
  }

  tags = {
    Environment = var.environment
    Project     = "Serverless FinOps"
  }
}