import os
import json
import boto3
import logging

from decimal import Decimal

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize DynamoDB resource and table
dynamodb = boto3.resource("dynamodb")
table_name = os.environ.get("DYNAMODB_TABLE_NAME")
if not table_name:
    raise ValueError("DYNAMODB_TABLE_NAME environment variable is not set")

table = dynamodb.Table(table_name)


class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return str(obj)
        return json.JSONEncoder.default(self, obj)


def lambda_handler(event, context):
    try:
        items = []
        response = table.scan()

        # Loop through paginated results
        while "LastEvaluatedKey" in response:
            items.extend(response["Items"])
            response = table.scan(ExclusiveStartKey=response["LastEvaluatedKey"])

        items.extend(response["Items"])

        return {
            "statusCode": 200,
            "body": json.dumps(items, cls=DecimalEncoder),
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET,OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type,Authorization",
            },
        }
    except Exception as e:
        logger.error("Error scanning table: %s", e)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)}),
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET,OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type,Authorization",
            },
        }
