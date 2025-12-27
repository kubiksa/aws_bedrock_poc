locals {
  bucket_name = (
    var.kb_s3_bucket_name != "" ?
    var.kb_s3_bucket_name :
    "${var.project_name}-kb-docs"
  )
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ===== S3 BUCKET FOR DOCUMENTS (DATA SOURCE) =====
resource "aws_s3_bucket" "kb_docs" {
  count  = var.kb_s3_bucket_name == "" ? 1 : 0
  bucket = local.bucket_name
}

# ===== IAM ROLE FOR BEDROCK KB =====
resource "aws_iam_role" "kb_role" {
  name = "${var.project_name}-kb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "bedrock.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# ===== IAM POLICY FOR S3 + S3 VECTORS + BEDROCK =====
resource "aws_iam_role_policy" "kb_policy" {
  name = "${var.project_name}-kb-policy"
  role = aws_iam_role.kb_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # S3 data source access
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${local.bucket_name}",
          "arn:aws:s3:::${local.bucket_name}/*"
        ]
      },
      # S3 Vectors access (for when KB is created)
      {
        Effect = "Allow"
        Action = [
          "s3vectors:*",  
          "s3vectors:GetVectorBucket",
          "s3vectors:ListVectorIndexes",
          "s3vectors:GetIndex",
          "s3vectors:PutVector",
          "s3vectors:GetVector",
          "s3vectors:DeleteVector",
          "s3vectors:QueryVectors"
        ]
        Resource = [
          "arn:aws:s3vectors:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:bucket/*"
        ]
      },
      # Bedrock model access
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = "arn:aws:bedrock:${data.aws_region.current.region}::foundation-model/${var.embedding_model_id}"
      }
    ]
  })
}

