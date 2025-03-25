# Define an archive_file datasource that creates the lambda archive
data "archive_file" "lambda1" {
 type        = "zip"
 source_file = "getTextFunction.py"
 output_path = "getTextFunction.zip"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func1.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}

resource "aws_lambda_function" "func1" {
 function_name = "getTextFunction"
 role          = aws_iam_role.lambda_exec_role.arn
 handler       = "getTextFunction.lambda_handler"
 runtime       = "python3.13"
 filename      = data.archive_file.lambda1.output_path
}

# aws_cloudwatch_log_group to get the logs of the Lambda execution.
resource "aws_cloudwatch_log_group" "lambda1_log_group" {
 name              = "/aws/lambda/getTextFunction"
 retention_in_days = 14
}

# Create IAM role for getTextLambda funcition 
resource "aws_iam_role" "lambda_exec_role" {
 name = "getTextLambda_role"
  assume_role_policy = jsonencode({
   Version = "2012-10-17",
   Statement = [
     {
       Action = "sts:AssumeRole",
       Principal = {
         Service = "lambda.amazonaws.com"
       },
       Effect = "Allow"
     }
   ]
 })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
 role       = aws_iam_role.lambda_exec_role.name
 policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda1_S3_FullAccess" {
 role       = aws_iam_role.lambda_exec_role.name
 policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda1_textract_FullAccess" {
 role       = aws_iam_role.lambda_exec_role.name
 policy_arn = "arn:aws:iam::aws:policy/AmazonTextractFullAccess"
}