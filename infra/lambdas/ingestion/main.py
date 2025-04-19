import boto3
import os
import json

s3 = boto3.client('s3')
eventbridge = boto3.client('eventbridge')

def handler(event, context):
    try:
        # Process uploaded invoice
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']
        
        # Send event to EventBridge
        eventbridge.put_events(
            Entries=[{
                'Source': 'invoice.ingestion',
                'DetailType': 'InvoiceUploaded',
                'Detail': json.dumps({'bucket': bucket, 'key': key}),
                'EventBusName': os.environ['EVENT_BUS_NAME']
            }]
        )
        
        return {'statusCode': 200}
    except Exception as e:
        print(e)
        return {'statusCode': 500}