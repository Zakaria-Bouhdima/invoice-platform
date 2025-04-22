import os
import boto3
import json
from botocore.exceptions import ClientError
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
ses = boto3.client('ses')  # For sending emails
third_party_client = boto3.client('http')  # Mock placeholder for third-party API calls

def handler(event, context):
    try:
        # Extract clientId and transformed data from the event
        client_id = event['detail']['clientId']
        transformed_data = event['detail']['transformedData']  # Already transformed JSON
        logger.info(f"Distributing invoice for clientId: {client_id}")

        # Call the third-party API
        response = call_third_party_api(transformed_data)
        if response['status'] != 'success':
            logger.error(f"Third-party API call failed: {response}")
            return {'statusCode': 500, 'body': 'Third-party API call failed'}

        # Notify the client via email (optional)
        send_notification_email(
            to_address="client@example.com",  # Replace with actual client email
            subject="Invoice Processed",
            body=f"Invoice for {client_id} has been successfully processed."
        )

        logger.info("Distribution completed successfully.")
        return {'statusCode': 200, 'body': 'Success'}
    except ClientError as e:
        logger.error(f"AWS Error: {e.response['Error']['Message']}")
        return {'statusCode': 500, 'body': 'AWS Service Error'}
    except Exception as e:
        logger.error(f"Error during distribution: {str(e)}")
        return {'statusCode': 500, 'body': 'Internal Server Error'}

def call_third_party_api(data):
    """
    Simulates calling a third-party API.
    Replace this with actual API integration logic.
    """
    try:
        # Example: Call a third-party API using boto3 or requests
        # response = requests.post(url, json=data, headers=headers)
        # return {'status': 'success', 'data': response.json()}

        # Mock response for demonstration purposes
        logger.info("Calling third-party API with data: %s", data)
        return {'status': 'success', 'message': 'API call successful'}
    except Exception as e:
        logger.error(f"Error calling third-party API: {str(e)}")
        return {'status': 'failure', 'message': str(e)}

def send_notification_email(to_address, subject, body):
    """
    Sends an email notification to the client.
    """
    try:
        ses.send_email(
            Source=os.environ['SES_SENDER_EMAIL'],  # Sender email address
            Destination={'ToAddresses': [to_address]},
            Message={
                'Subject': {'Data': subject},
                'Body': {'Text': {'Data': body}}
            }
        )
        logger.info(f"Notification email sent to {to_address}")
    except ClientError as e:
        logger.error(f"SES Error: {e.response['Error']['Message']}")
        raise