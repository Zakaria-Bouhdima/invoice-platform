import json
import os
import boto3
from boto3.dynamodb.conditions import Key

s3 = boto3.client("s3")
dynamodb = boto3.resource("dynamodb")
sqs = boto3.client("sqs")

S3_BUCKET = os.environ["S3_BUCKET"]
DYNAMODB_TABLE = os.environ["DYNAMODB_TABLE"]
SQS_QUEUE_URL = os.environ["SQS_QUEUE_URL"]

table = dynamodb.Table(DYNAMODB_TABLE)


def handler(event, context):
    for record in event["Records"]:
        message = json.loads(record["body"])
        invoice_id = message["invoiceId"]
        client_id = message["clientId"]
        s3_key = message["s3Key"]

        raw = json.loads(
            s3.get_object(Bucket=S3_BUCKET, Key=s3_key)["Body"].read()
        )

        rules = _get_rules(client_id)
        transformed = _apply_rules(raw, rules)

        transformed_key = f"transformed/{client_id}/{invoice_id}.json"
        s3.put_object(
            Bucket=S3_BUCKET,
            Key=transformed_key,
            Body=json.dumps(transformed),
            ContentType="application/json",
        )

        sqs.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=json.dumps({
                "invoiceId": invoice_id,
                "clientId": client_id,
                "s3Key": transformed_key,
            }),
        )


def _get_rules(client_id):
    response = table.query(
        KeyConditionExpression=Key("clientId").eq(client_id),
        ScanIndexForward=False,
        Limit=1,
    )
    items = response.get("Items", [])
    return items[0].get("rules", []) if items else []


def _apply_rules(data, rules):
    result = dict(data)
    for rule in rules:
        if rule["ruleType"] == "rename" and rule["sourceField"] in result:
            result[rule["targetField"]] = result.pop(rule["sourceField"])
        elif rule["ruleType"] == "static":
            result[rule["sourceField"]] = rule["staticValue"]
    return result
