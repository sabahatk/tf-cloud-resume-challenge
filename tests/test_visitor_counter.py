import boto3
import pytest
from src.lambda_visitor_counter import lambda_handler as update_handler
from src.lambda_visitor_counter_retrieve_item import lambda_handler as retrieve_handler
from moto import mock_aws # install using pip install 'moto[ec2,s3,all]'

@mock_aws
def test_lambda_visitor_counter():
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.create_table(
        TableName="VisitCounterDB",
        KeySchema=[{'AttributeName': 'counter-id', 'KeyType': 'HASH'}],
        AttributeDefinitions=[{'AttributeName': 'counter-id', 'AttributeType': 'S'}],
        ProvisionedThroughput={'ReadCapacityUnits': 1, 'WriteCapacityUnits': 1}
    )

    table.put_item(Item={"counter-id": "1", "counterVal": 0})
    event = {"counter-id": "1", "counterVal": 0}
    response = retrieve_handler(event, context={})

    body = response["body"]
    expected_body = "{\"body\": 0.0}"
    if body == expected_body:
        print("SUCCESS")

    print("RESPONSE is:", body, "type:", type(body))
    print("TEST Response is: ", expected_body, "type", type(expected_body))
    print("Check values", body == expected_body)
    assert body == expected_body

#test_lambda_visitor_counter()



