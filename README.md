# Serverless Invoice Processing Platform

This project implements a serverless platform for processing OCR-processed invoices. It allows clients to upload invoices, apply configurable transformation rules, and distribute the transformed data to third-party APIs.

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [Deployment](#deployment)
5. [Modules](#modules)
6. [Testing](#testing)
7. [Contributing](#contributing)

---

## Overview

The platform is designed to handle up to **5000 invoices/hour** with near real-time processing. Key features include:
- **Ingestion**: Receive JSON invoices via API Gateway.
- **Transformation**: Apply client-specific transformation rules using Lambda functions.
- **Distribution**: Send transformed data to third-party APIs.
- **Security**: OAuth2 authentication via Cognito and HTTPS encryption.
- **Extensibility**: Modular design to support additional third-party integrations.

---

## Architecture

The system uses a modular serverless architecture based on AWS services:
- **API Gateway**: Exposes endpoints for receiving invoices.
- **Lambda Functions**:
  - `invoice-ingestion`: Validates and stores incoming invoices.
  - `invoice-transformation`: Applies transformation rules stored in DynamoDB.
  - `invoice-distribution`: Sends transformed data to third-party APIs.
- **DynamoDB**: Stores client-specific transformation rules.
- **S3**: Stores raw JSON and original documents.
- **EventBridge**: Orchestrates workflows between Lambda functions.
- **CloudFront**: Hosts frontend assets for the web interface.

---

## Prerequisites

Before deploying the platform, ensure you have the following:
1. **AWS Account**: With sufficient permissions to create resources.
2. **Terraform**: Installed locally (`>= v1.0`).
3. **GitHub Repository**: For CI/CD pipeline integration.
4. **ACM Certificate**: For CloudFront HTTPS support.
5. **Python 3.9**: For Lambda function development.

---

## Deployment

### Step 1: Initialize Terraform
Run the following commands to initialize Terraform and download providers:
```bash
terraform init