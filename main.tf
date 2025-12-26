resource "aws_iam_policy" "policy" {
  name  = "${var.component}-${var.env}-ssm-pm-policy"
  path = "/"
  description = "${var.component}-${var.env}-ssm-pm-policy"

  policy = jsonencode( {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameterHistory",
                "ssm:GetParametersByPath",
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:us-east-1:950538586636:parameter/roboshop.${var.env}.${var.component}.*"
        }
    ]
})
  }

# I AM ROLE
