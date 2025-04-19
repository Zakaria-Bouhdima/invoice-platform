import os
import boto3
import json
from textract import process  # For PDF/text extraction
from datetime import datetime

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

def handler(event, context):
    try:
        # Get invoice from S3
        bucket = event['detail']['bucket']
        key = event['detail']['key']
        response = s3.get_object(Bucket=bucket, Key=key)
        
        # Extract text with Textract
        text = process(response['Body'].read())
        
        # Save to DynamoDB
        table.put_item(
            Item={
                'clientId': key.split('/')[0],  # Assuming key format: clientID/invoice.pdf
                'version': datetime.utcnow().isoformat(),
                'content': text,
                'status': 'PROCESSED'
            }
        )
        
        # Trigger distribution step
        client = boto3.client('eventbridge')
        client.put_events(
            Entries=[{
                'Source': 'invoice.transformation',
                'DetailType': 'ProcessingComplete',
                'Detail': json.dumps({'clientId': key.split('/')[0]}),
                'EventBusName': 'default'
            }]
        )
        
    except Exception as e:
        print(f"Error: {str(e)}")
        raise