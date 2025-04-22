import os
import boto3
import json
from datetime import datetime
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
textract = boto3.client('textract')

table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

def handler(event, context):
    try:
        # Extract bucket and key from the event
        bucket = event['detail']['bucket']
        key = event['detail']['key']
        logger.info(f"Processing file: {key} from bucket: {bucket}")

        # Retrieve the file from S3
        s3_response = s3.get_object(Bucket=bucket, Key=key)
        file_content = s3_response['Body'].read()

        # Process the file with Textract
        textract_response = textract.detect_document_text(Document={'Bytes': file_content})
        text = "\n".join([item['Text'] for item in textract_response['Blocks'] if item['BlockType'] == 'LINE'])

        # Save the processed data to DynamoDB
        table.put_item(
            Item={
                'clientId': key.split('/')[0],  # Assuming key format: clientID/invoice.pdf
                'version': datetime.utcnow().isoformat(),
                'content': text,
                'status': 'PROCESSED'
            }
        )
        logger.info("Data saved to DynamoDB.")

        # Trigger the distribution step
        eventbridge = boto3.client('eventbridge')
        eventbridge.put_events(
            Entries=[{
                'Source': 'invoice.transformation',
                'DetailType': 'ProcessingComplete',
                'Detail': json.dumps({'clientId': key.split('/')[0]}),
                'EventBusName': 'default'
            }]
        )
        logger.info("Event sent to EventBridge for distribution.")

        return {'statusCode': 200, 'body': 'Success'}
    except Exception as e:
        logger.error(f"Error during transformation: {str(e)}")
        return {'statusCode': 500, 'body': 'Internal Server Error'}