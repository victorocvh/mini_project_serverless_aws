import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('serveless-aws')

def lambda_handler(event, context):
  data = table.scan()
  return data['Items']
