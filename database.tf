# Create Azure Cosmos DB Account in Serverless Mode
resource "azurerm_cosmosdb_account" "cosmos" {
    name  = "${var.prefix}-cosmos-${var.environment}"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    offer_type = "Standard"
    kind = "GlobalDocumentDB"

    # Enable Serverless capabilities
    capabilities {
        name = "EnableServerless"
    }

    consistency_policy {
        consistency_level = "Session"
    }

    geo_location {
        location = azurerm_resource_group.rg.location
        failover_priority = 0
    }

    tags = {
        Environment = var.environment
        Projects = "Serverless Finops"
    }
}

# Create Cosmos DB SQL Database
resource "azurerm_cosmosdb_sql_database" "db" {
    name = "finopsdb"
    resource_group_name = azurerm_resource_group.rg.name
    account_name = azurerm_cosmosdb_account.cosmos.name
}


resource "azurerm_cosmosdb_sql_container" "container" {
    name = "events"
    resource_group_name = azurerm_resource_group.rg.name
    account_name = azurerm_cosmosdb_account.cosmos.name
    database_name = azurerm_cosmosdb_sql_database.db.name
    partition_key_paths = ["/id"]
}