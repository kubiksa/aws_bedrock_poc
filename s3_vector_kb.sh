#!/bin/bash
PROJECT_NAME="compliance-copilot"
REGION="us-west-2"

# Create vector bucket
aws s3vectors create-vector-bucket \
  --vector-bucket-name "${PROJECT_NAME}-kb-vectors" \
  --region $REGION

# Create vector index (dimension must match your embedding model)
aws s3vectors create-index \
  --vector-bucket-name "${PROJECT_NAME}-kb-vectors" \
  --index-name "bedrock-kb-index" \
  --data-type "float32" \
  --dimension 1024 \
  --distance-metric "euclidean" \
  --region $REGION  
