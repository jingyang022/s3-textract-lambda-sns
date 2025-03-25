data "archive_file" "lambda2" {
 type        = "zip"
 source_file = "writeResultsToS3.py"
 output_path = "writeResultsToS3.zip"
}

resource "aws_lambda_permission" "allow_SNS" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func2.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.yap_topic.arn
}

resource "aws_lambda_function" "func2" {
 function_name = "writeResultsFunction"
 role          = aws_iam_role.lambda2_exec_role.arn
 handler       = "writeResultsToS3.lambda_handler"
 runtime       = "python3.13"
 filename      = data.archive_file.lambda2.output_path
}

# aws_cloudwatch_log_group to get the logs of the Lambda execution.
resource "aws_cloudwatch_log_group" "lambda2_log_group" {
 name              = "/aws/lambda/writeResultsToS3"
 retention_in_days = 14
}

# Create IAM role for WriteResultsLambda function
resource "aws_iam_role" "lambda2_exec_role" {
 name = "WriteResultsLambda_role"
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

resource "aws_iam_role_policy_attachment" "lambda2_basic_execution" {
 role       = aws_iam_role.lambda2_exec_role.name
 policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda2_S3_FullAccess" {
 role       = aws_iam_role.lambda2_exec_role.name
 policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda2_textract_FullAccess" {
 role       = aws_iam_role.lambda2_exec_role.name
 policy_arn = "arn:aws:iam::aws:policy/AmazonTextractFullAccess"
}

