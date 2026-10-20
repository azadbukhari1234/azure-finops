import azure.functions as func
import logging
import json
import os
from azure.cosmos import CosmosClient, exceptions

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="processevent", methods=["POST"])
def processevent(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    try:
        req_body = req.get_json()
    except ValueError:
        return func.HttpResponse(
            "Invalid JSON payload",
            status_code=400
        )

    # Retrieve Cosmos DB configuration from environment variables (set by Terraform)
    endpoint = os.environ.get("COSMOS_DB_ENDPOINT")
    key = os.environ.get("COSMOS_DB_KEY")
    database_name = os.environ.get("COSMOS_DB_NAME")
    container_name = os.environ.get("COSMOS_CONTAINER")

    if not endpoint or not key:
        return func.HttpResponse("Cosmos DB credentials not configured", status_code=500)

    try:
        client = CosmosClient(endpoint, key)
        database = client.get_database_client(database_name)
        container = database.get_container_client(container_name)

        # Insert event log into Cosmos DB Serverless
        container.create_item(body=req_body)

    except exceptions.CosmosHttpResponseError as e:
        logging.error(f"Cosmos DB error: {e}")
        return func.HttpResponse(f"Database error: {e.message}", status_code=500)

    return func.HttpResponse(
        json.dumps({"status": "Success", "message": "Event processed and stored serverlessly!"}),
        status_code=200,
        mimetype="application/json"
    )