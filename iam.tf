resource "aws_iam_role" "lambda_role" {
  name = "api-lambda-role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-policy"
  description = "IAM policy for a lambda"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeInstances",
            "ec2:AttachNetworkInterface",
            "ssm:PutParameter",
          "ssm:DeleteParameter",
          "ssm:GetParameterHistory",
          "ssm:GetParameter"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : ["dynamodb:PutItem", "dynamodb:Scan"],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:PutObject",
            "s3:GetObject"
          ],
          "Resource" : ["*"]

        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents",
            "logs:GetLogEvents",
            "logs:FilterLogEvents"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "lambda:InvokeFunction",
          "Resource" : ["*"]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.id
  policy_arn = aws_iam_policy.lambda_policy.id
}
resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_cognito" {
  role       = aws_iam_role.lambda_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}
resource "aws_iam_role_policy_attachment" "full_admin" {
  role       = aws_iam_role.lambda_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


resource "aws_iam_role_policy" "cognito_lambda" {
  name = "cognito-lambda"
  role = aws_iam_role.cognito_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
        Sid = "AllowAll",
        Effect = "Allow",
        Action = ["lambda:InvokeFunction"],
        Resource = aws_lambda_function.myfunction.arn
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_policy_attach_cog" {
  role       = aws_iam_role.cognito_role.id
  policy_arn = aws_iam_policy.cognito_permissions.id
}
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_cog" {
  role       = aws_iam_role.cognito_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_cognito_cog" {
  role       = aws_iam_role.cognito_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}
resource "aws_iam_role_policy_attachment" "full_admin_cog" {
  role       = aws_iam_role.cognito_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role" "cognito_role" {
  name = "cognito-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "cognito-idp.amazonaws.com"  
      }
    }]
  })
}

resource "aws_iam_policy" "cognito_permissions" {

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "CognitoLambda",
        "Effect": "Allow",
        "Action": ["lambda:InvokeFunction"],
        "Resource": ["*"]
      }
    ] 
  })
}


resource "aws_vpc_endpoint_policy" "example" {
  vpc_endpoint_id = aws_vpc_endpoint.dynamodbVP.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowAll",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : [
          "*"
        ],
        "Resource" : "*"
      }
    ]
  })
}