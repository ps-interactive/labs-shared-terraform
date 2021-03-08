import boto3
import uuid
from decimal import Decimal
import json
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('globoticket_table')

class InvalidQuantity(Exception):
    def __init__(self, message=None, details=None):
        self.message = message or "Payment failed"
        self.details = details or {}

def lambda_handler(event, context):    
    booking_id = event['booking_id']

    # simulation of payment processing and update the payment_status to success
    
    ddb_response = table.get_item(Key = {'booking_id': booking_id })
    quantity = ddb_response['Item']['quantity']
    
    try:
        if quantity < 1:
            raise InvalidQuantity
        else: 
            ddb_response = table.update_item(
                    Key = {
                        'booking_id': booking_id,
                    },
                    UpdateExpression= "set payment_status=:status",
                    ExpressionAttributeValues= {
                        ':status': "SUCCESS"
                    },
                    ReturnValues="UPDATED_NEW"
                )
            
            response = {
                "booking_id": booking_id,
                "payment_status": ddb_response['Attributes']["payment_status"]
            }
        return response
        
    except InvalidQuantity as err:
        raise
