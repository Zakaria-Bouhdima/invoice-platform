import os
import boto3
import json
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')
eventbridge = boto3.client('eventbridge')

def handler(event, context):
    try:
        # Validate input
        if 'Records' not in event or len(event['Records']) == 0:
            logger.error("Invalid event: No Records found.")
            return {'statusCode': 400, 'body': 'Invalid event'}

        record = event['Records'][0]
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        logger.info(f"Processing file: {key} from bucket: {bucket}")

        # Send event to EventBridge
        response = eventbridge.put_events(
            Entries=[{
                'Source': 'invoice.ingestion',
                'DetailType': 'InvoiceUploaded',
                'Detail': json.dumps({'bucket': bucket, 'key': key}),
                'EventBusName': os.environ['EVENT_BUS_NAME']
            }]
        )

        # Check for EventBridge errors
        if response['FailedEntryCount'] > 0:
            logger.error(f"Failed to send event to EventBridge: {response}")
            return {'statusCode': 500, 'body': 'Failed to send event to EventBridge'}

        logger.info("Event successfully sent to EventBridge.")
        return {'statusCode': 200, 'body': 'Success'}
    except Exception as e:
        logger.error(f"Error processing event: {str(e)}")
        return {'statusCode': 500, 'body': 'Internal Server Error'}