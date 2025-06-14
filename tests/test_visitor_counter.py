import boto3
import pytest
from src.lambda_visitor_counter import lambda_handler as update_handler
from src.lambda_visitor_counter_retrieve_item import lambda_handler as retrieve_handler
from moto import mock_aws # install using pip install 'moto[ec2,s3,all]'

#Create a mock dynamodb table
@mock_aws
def test_lambda_visitor_counter():
    #retrieve the dynamodb resource
    dynamodb = boto3.resource('dynamodb')
    #Create a mock dynamodb table
    table = dynamodb.create_table(
        TableName="VisitCounterDB",
        KeySchema=[{'AttributeName': 'counter-id', 'KeyType': 'HASH'}],
        AttributeDefinitions=[{'AttributeName': 'counter-id', 'AttributeType': 'S'}],
        ProvisionedThroughput={'ReadCapacityUnits': 1, 'WriteCapacityUnits': 1}
    )
    table.put_item(Item={"counter-id": "1", "counterVal": 0}) #Create an item for mock table
    event = {"counter-id": "1", "counterVal": 0} #Event is the item

    
    response = retrieve_handler(event, context={}) #retrieve the value before updating the counter
    body = response["body"] #retrieve only the body portion of the response
    expected_body = "{\"body\": 0.0}" #Expected result before update
    assert body == expected_body #Check to see if the value is correctly getting retrieveed before the counter update

    update_handler(event, context={}) #Update the mock table counter
    response = retrieve_handler(event, context={}) #retrieve the counter again after the update

    body = response["body"] #Retrieve only the body from the response
    expected_body = "{\"body\": 1.0}" #expected result after update
    if body == expected_body: #Success message
        print("SUCCESS")

    assert body == expected_body #Assert that the correct value happens after the counter update

#test_lambda_visitor_counter() #Run the function



