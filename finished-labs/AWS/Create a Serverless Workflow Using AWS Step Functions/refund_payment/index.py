import boto3
import uuid
from decimal import Decimal
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('globoticket_table')

def lambda_handler(event, context):
    
    booking_id = event['booking_id']

    # simulation of the refund process and update the payment_status to REFUND

    ddb_response = table.update_item(
            Key = {
                'booking_id': booking_id,
            },
            UpdateExpression= "set payment_status=:status",
            ExpressionAttributeValues= {
                ':status': "CANCELLED"
            },
            ReturnValues="UPDATED_NEW"
        )
    
    response = {
        "booking_id": booking_id
    }
    
    return response
