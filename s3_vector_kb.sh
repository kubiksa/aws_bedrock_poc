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



  # Replace <ROLE_ARN> with the ARN from above
aws bedrock-agent update-agent \
  --agent-id YA9QR6THMX \
  --agent-name "compliance-copilot-agent" \
  --agent-resource-role-arn arn:aws:iam::015355410250:role/compliance-copilot-agent-role \
  --foundation-model "us.amazon.nova-lite-v1:0" \
  --instruction "You are a helpful compliance assistant for water and wastewater utilities. Use the knowledge base to answer questions about regulations, standards, and compliance requirements. Always cite sources from the knowledge base when providing answers. If you don't find relevant information in the knowledge base, say so clearly." \
  --region us-west-2 \
  --no-cli-pager

# Wait 10 seconds
sleep 10

# Prepare the agent
aws bedrock-agent prepare-agent \
  --agent-id YA9QR6THMX \
  --region us-west-2 \
  --no-cli-pager

  # Use the alias ID you just got
aws bedrock-agent-runtime invoke-agent \
  --agent-id $AGENT_ID \
  --agent-alias-id <NEW_ALIAS_ID> \
  --session-id "test-$(date +%s)" \
  --input-text "What security measures are required?" \
  --region us-west-2 \
  response.json --no-cli-pager

cat response.json
