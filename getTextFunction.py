import json
import urllib.parse
import boto3

print('Loading function')

def lambda_handler(event, context):
    print("Triggered getTextFromS3PDF event: " + json.dumps(event, indent=2))

    # Get the object from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    try:
        textract = boto3.client('textract')
        textract.start_document_text_detection(
        DocumentLocation={
            'S3Object': {
                'Bucket': bucket,
                'Name': key
            }
        },
        JobTag=key + '_Job',
        NotificationChannel={
            'RoleArn': 'arn:aws:iam::255945442255:role/AWSSNSFullAccessRole',
            'SNSTopicArn': 'arn:aws:sns:ap-southeast-1:255945442255:TextProcess_Completed'
        })
        
        return 'Triggered PDF Processing for ' + key
    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
        raise e