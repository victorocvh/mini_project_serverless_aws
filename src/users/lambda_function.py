import boto3
import uuid
import os
from boto3.dynamodb.types import TypeSerializer
import json
from datetime import datetime


def python_to_dynamo(python_object: dict) -> dict:
    serializer = TypeSerializer()
    return {
        k: serializer.serialize(v)
        for k, v in python_object.items()
    }


def get_user(dynamodb_client: any, table_name: str, userid: str):
    return dynamodb_client.get_item(
        TableName=table_name,
        Key={
            'userid': {
                'S': userid,
            }
        },
        ReturnConsumedCapacity='TOTAL'
    )


def delete_user(dynamodb_client: any, table_name: str, userid: str):

    return dynamodb_client.delete_item(
        TableName=table_name,
        Key={
            'userid': {'S': userid}
        },
        ReturnConsumedCapacity='TOTAL'
    )


def update_item(dynamodb_client: any, table_name: str, item: any):

    return dynamodb_client.put_item(
        TableName=table_name,
        Item=item
    )


def put_item(dynamodb_client: any, table_name: str, item: any):
    return dynamodb_client.put_item(
        TableName=table_name,
        Item=json.loads(json.dumps(item)),
        ConditionExpression='attribute_not_exists(userid)'
    )


def lambda_handler(event, context):

    dynamodb = boto3.client('dynamodb')
    table_name = os.getenv('USERS_TABLE') or 'dev_Users'
    body = None

    if (event['httpMethod'] == 'GET'):
        body = get_user(dynamodb, table_name, event['body']['userid'])

    if (event['httpMethod'] == 'DELETE'):
        body = delete_user(dynamodb, table_name, event['body']['userid'])

    if (event['httpMethod'] == 'PUT' and event['body']['userid']):
        updatedItem = event['body']
        updatedItem['timestamp'] = datetime.now().isoformat()
        updatedItem['userid'] = event['body']['userid']
        updatedItem = python_to_dynamo(updatedItem)
        body = update_item(dynamodb, table_name, updatedItem)
    if (event['httpMethod'] == 'POST'):
        newItem = event['body']
        newItem['timestamp'] = datetime.now().isoformat()
        newItem["userid"] = str(uuid.uuid4())
        newItem = python_to_dynamo(newItem)
        body = put_item(dynamodb, table_name, newItem)

    return {
        "body": json.dumps(body),
        "statusCode": 200,
        "headers": {},
        "isBase64Encoded": False
    }
