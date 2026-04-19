import json
import os
import uuid
import boto3

s3 = boto3.client("s3")
sqs = boto3.client("sqs")

S3_BUCKET = os.environ["S3_BUCKET"]
SQS_QUEUE_URL = os.environ["SQS_QUEUE_URL"]


def handler(event, context):
    try:
        body = json.loads(event.get("body") or "{}")
    except json.JSONDecodeError:
        return _response(400, {"error": "Invalid JSON body"})

    client_id = body.get("clientId")
    if not client_id:
        return _response(400, {"error": "clientId is required"})

    invoice_id = str(uuid.uuid4())
    s3_key = f"raw/{client_id}/{invoice_id}.json"

    s3.put_object(
        Bucket=S3_BUCKET,
        Key=s3_key,
        Body=json.dumps(body),
        ContentType="application/json",
    )

    sqs.send_message(
        QueueUrl=SQS_QUEUE_URL,
        MessageBody=json.dumps({
            "invoiceId": invoice_id,
            "clientId": client_id,
            "s3Key": s3_key,
        }),
    )

    return _response(202, {"invoiceId": invoice_id, "status": "accepted"})


def _response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }
