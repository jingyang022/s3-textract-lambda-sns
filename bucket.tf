resource "aws_s3_bucket" "bucket" {
  bucket = "yap-textract-bucket"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.func1.arn
    events              = ["s3:ObjectCreated:*"]
    #filter_prefix       = "uploads/"
    #filter_suffix       = ".log"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}