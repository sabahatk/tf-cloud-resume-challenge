import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('VisitCounterDB')


response = table.get_item(
Key={'counter-id': '1'},
    ConsistentRead=True,
    ProjectionExpression='counterVal',
)
if 'Item' in response:
    item = response['Item']
print("Response is: ", item)
counter_value = item['counterVal']

if counter_value:
    print("The counter value is: ", counter_value)