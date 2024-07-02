terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Create an S3 bucket with additional configurations
resource "aws_s3_bucket" "my_bucket" {
  bucket = "scdoa2724"  # Replace with your unique bucket name
  acl    = "private"

  # Bucket Object Ownership configuration
  object_ownership {
    object_ownership = "BucketOwnerPreferred"
  }

  # Enable Bucket Versioning
  versioning {
    enabled = true
  }

  # Server-Side Encryption by Default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "my-bucket"
    Environment = "Dev"
  }
}

# Create an S3 bucket policy to enforce Object Ownership
resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.my_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

