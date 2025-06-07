import json
import boto3



def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('VisitCounterDB')
    response = table.update_item(
      Key={'counter-id': '1'},
      UpdateExpression='SET counterVal = counterVal + :incr',
      ExpressionAttributeValues={':incr': 1},
      ReturnValues="UPDATED_NEW"
    )
    print(response['Attributes'])

    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': '*'
        },
        'body': json.dumps('Updated Visitor Counter Successfully')
    }
