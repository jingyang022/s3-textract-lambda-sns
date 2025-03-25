#Create SNS topic
resource "aws_sns_topic" "yap_topic" {
  name = "TextProcess_Completed"
}

# Create SNS topic subscription
resource "aws_sns_topic_subscription" "sns-email-target" {
  topic_arn = aws_sns_topic.yap_topic.arn
  protocol  = "email"
  endpoint  = "jingyang022@yahoo.com.sg"
}

# Creating an IAM Role AWS SNS Access
resource "aws_iam_role" "textract_exec_role" {
 name = "AWSSNSFullAccessRole"
  assume_role_policy = jsonencode({
   Version = "2012-10-17",
   Statement = [
     {
       Action = "sts:AssumeRole",
       Principal = {
         Service = "textract.amazonaws.com"
       },
       Effect = "Allow"
     }
   ]
 })
}

resource "aws_iam_role_policy_attachment" "TextractServiceRole" {
 role       = aws_iam_role.textract_exec_role.name
 policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonTextractServiceRole"
}

resource "aws_iam_role_policy_attachment" "SNS_FullAccess" {
 role       = aws_iam_role.textract_exec_role.name
 policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}