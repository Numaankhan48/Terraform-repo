# --------------------------
# 1️⃣  IAM Role for Lambda
# --------------------------
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# --------------------------
# 2️⃣  Create S3 bucket
# --------------------------
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "numaam-lambda-bucket-2025" # change this to a unique name globally

  tags = {
    Name = "Lambda Bucket"
  }
}

# --------------------------
# 3️⃣  Upload ZIP file to S3
# --------------------------
resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_bucket.bucket
  key    = "lambda_function.zip"   # name in S3
  source = "lambda_function.zip"   # local file path
  etag   = filemd5("lambda_function.zip")
}

# --------------------------
# 4️⃣  Create Lambda using S3 source
# --------------------------
resource "aws_lambda_function" "my_lambda" {
  function_name = "my_lambda_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  timeout       = 900
  memory_size   = 128

  # Instead of filename, we use S3 bucket details:
  s3_bucket = aws_s3_bucket.lambda_bucket.bucket
  s3_key    = aws_s3_object.lambda_code.key

  # Optional hash to trigger updates automatically
  source_code_hash = filebase64sha256("lambda_function.zip")

  depends_on = [aws_s3_object.lambda_code]
}
