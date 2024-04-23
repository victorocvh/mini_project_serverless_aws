import boto3
import uuid

def lambda_handler(event, context):
    table_name = 'serveless-aws'
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name)

    result = None
    people = [
            { 'userid' : 'marivera', 'name' : 'Martha Rivera'},
            { 'userid' : 'nikkwolf', 'name' : 'Nikki Wolf'},
            { 'userid' : 'pasantos', 'name' : 'Paulo Santos'},
            { 'userid' : 'victorocv', 'name' : 'Victor Carvalho Ribeiro'}
        ]

    for person in people:
        item = {
            'PK': f"USER#{person['userid']}",
            'SK': f"#METADATA#{person['userid']}",
            'FullName': person['name']
        }
        print("> writing: {}".format(person['userid']))
        condition_expression = 'attribute_not_exists(PK) AND attribute_not_exists(SK)'  
        # Verifica se os atributos PK e SK não existem
        try:
            table.put_item(Item=item, ConditionExpression=condition_expression)
        except dynamodb.meta.client.exceptions.ConditionalCheckFailedException:
            print(f"Item already exists: {person['userid']}")

    result = f"Success. Added {len(people)} people to {table.name}."

    return {'message': result}
