import boto3
import uuid
import json
from decimal import Decimal
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('globoticket_table')

lambda_client = boto3.client('lambda')

def lambda_handler(event, context):
    
    booking_id = str(uuid.uuid4())
    customer_id = event['customer_id']
    quantity = event['quantity']

    booking_item = {
                'booking_id': booking_id,
                'customer_id': customer_id ,
                'quantity': quantity,
                'total_cost': Decimal(quantity * 20.00),
                'payment_status': "PENDING"
            }

    ddb_response = table.put_item(Item=booking_item)
    
    response = {
        "booking_id": booking_id,
        "customer_id": customer_id,
        "quantity": quantity,
        "payment_status": booking_item["payment_status"]
    }

   # lambda_client.invoke(FunctionName="collect-payment", Payload=json.dumps(response))
    
    return response
