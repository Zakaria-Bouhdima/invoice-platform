import json
import os
import time
import urllib.request
import urllib.error
import boto3

s3 = boto3.client("s3")

S3_BUCKET = os.environ["S3_BUCKET"]
THIRD_PARTY_APIS = json.loads(os.environ.get("THIRD_PARTY_APIS", "{}"))
MAX_ATTEMPTS = 3


def handler(event, context):
    for record in event["Records"]:
        message = json.loads(record["body"])
        s3_key = message["s3Key"]

        invoice = json.loads(
            s3.get_object(Bucket=S3_BUCKET, Key=s3_key)["Body"].read()
        )
        payload = json.dumps(invoice).encode()

        for name, url in THIRD_PARTY_APIS.items():
            _send_with_retry(name, url, payload)


def _send_with_retry(name, url, payload):
    for attempt in range(MAX_ATTEMPTS):
        try:
            req = urllib.request.Request(
                url,
                data=payload,
                headers={"Content-Type": "application/json"},
                method="POST",
            )
            with urllib.request.urlopen(req, timeout=10):
                return
        except urllib.error.URLError:
            if attempt < MAX_ATTEMPTS - 1:
                time.sleep(2 ** attempt)

    raise RuntimeError(f"All {MAX_ATTEMPTS} attempts to {name} ({url}) failed")
