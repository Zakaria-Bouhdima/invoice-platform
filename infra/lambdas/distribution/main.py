import os
import boto3
import json
from botocore.exceptions import ClientError

ses = boto3.client('ses')
s3 = boto3.client('s3')

def handler(event, context):
    try:
        client_id = event['detail']['clientId']
        
        # Get client rules from DynamoDB
        dynamodb = boto3.resource('dynamodb')
        table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])
        response = table.get_item(Key={'clientId': client_id})
        
        # Send email via SES
        send_email(
            to_address=response['Item']['email'],
            subject="Invoice Processed",
            body=f"Invoice for {client_id} is ready",
            attachment_url=f"s3://{os.environ['S3_BUCKET']}/{client_id}/processed_invoice.pdf"
        )
        
    except ClientError as e:
        print(f"AWS Error: {e.response['Error']['Message']}")
        raise

def send_email(to_address, subject, body, attachment_url):
    # SES implementation here
    pass