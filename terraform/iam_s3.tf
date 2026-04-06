# Random ID for S3 bucket
resource "random_id" "bucket_id" {
  byte_length = 4
}

# S3 Bucket
resource "aws_s3_bucket" "private_bucket" {
  bucket = "${var.project_name}-${var.environment}-${random_id.bucket_id.hex}"
  tags   = var.common_tags
}

# IAM Role for EC2 → S3
resource "aws_iam_role" "ec2_s3_role" {
  name = "${var.project_name}-ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_policy" {
  name   = "${var.project_name}-s3-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect = "Allow", Action = ["s3:ListBucket"], Resource = aws_s3_bucket.private_bucket.arn },
      { Effect = "Allow", Action = ["s3:GetObject","s3:PutObject"], Resource = "${aws_s3_bucket.private_bucket.arn}/*" }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_s3_role.name
}