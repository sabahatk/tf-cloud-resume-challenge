import json
import boto3

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('VisitCounterDB')


    response = table.get_item(
    Key={'counter-id': '1'},
        ConsistentRead=True,
        ProjectionExpression='counterVal',
    )

    if 'Item' in response:
        item = response['Item']
    counter_value = float(item['counterVal'])
    
    return {
        'statusCode': 200,
        'body': json.dumps({'body': counter_value}),
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': '*'
        },
    }