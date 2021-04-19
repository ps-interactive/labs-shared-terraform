##############################################
########### Challenge - 1 ####################
##############################################

#Creates an IAM Role
resource "aws_iam_role" "role" {
	name = "iam-pluralsight-role-for-state-machine-${terraform.workspace}"
	description = "Allows Step Functions to access AWS resources on your behalf."
	
	assume_role_policy = <<EOF
{
	  "Version": "2012-10-17",
	  "Statement": [
		{
		  "Action": "sts:AssumeRole",
		  "Principal": {
			"Service": "states.amazonaws.com"
		  },
		  "Effect": "Allow",
		  "Sid": ""
		}
	  ]
}
EOF
}

#Creates a new Policy to invoke Lambda function.
resource "aws_iam_policy" "policy" {
	name = "pluralsight-role-for-state-machine-policy-${terraform.workspace}"
	description = "Managed Policy for AWS Lambda service role."
	
	policy = <<EOF
{
	  "Version": "2012-10-17",
	  "Statement": [
		{
		  "Action": [
			"lambda:InvokeFunction"
		  ],
		  "Effect": "Allow",
		  "Resource": "*"
		}
	  ]
}
EOF
}

#Attach role and role-policy
resource "aws_iam_role_policy_attachment" "policy-role-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

##############################################
########### Challenge - 2 ####################
##############################################

#Creates a State Machine in Step Functions

resource "aws_sfn_state_machine" "hello_world_state_machine" {
  name     = "sf-pluralsight-hello-world-state-machine-${terraform.workspace}"
  role_arn = aws_iam_role.role.arn

  definition = <<EOF
{
  "Comment": "A Hello World example of the Amazon States Language using Pass states",
  "StartAt": "Hello",
  "States": {
    "Hello": {
      "Type": "Pass",
      "Result": "Hello",
      "ResultPath": "$.taskresult",
      "Next": "World"
    },
    "World": {
      "Type": "Pass",
      "Result": "World",
      "End": true
    }
  }
}
EOF
}

##############################################
########### Challenge - 3 ####################
##############################################

#Creates a new role for CloudWatch Events rule
resource "aws_iam_role" "role_for_events_rule" {
  name = "iam-pluralsight-invoke-hello-world-step-function-${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.role_for_events_rule_policy_document.json
}

data "aws_iam_policy_document" "role_for_events_rule_policy_document" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com"
      ]
    }
  }
}

#Creates a new policy for CloudWatch Events rule
resource "aws_iam_policy" "policy_for_events_rule_role" {
  name = "policy-for-events-rule-role-${terraform.workspace}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "states:StartExecution"
      ],
      "Resource": "${aws_sfn_state_machine.hello_world_state_machine.arn}"
    }
  ]
}
EOF
}


#Attach role and role-policy
resource "aws_iam_role_policy_attachment" "events-rule-role-policy-attach" {
  role       = aws_iam_role.role_for_events_rule.name
  policy_arn = aws_iam_policy.policy_for_events_rule_role.arn
}

# Creates a CloudWatch Events rule
resource "aws_cloudwatch_event_rule" "event_rule" {
  description         = "Creates a new CloudWatch Events rule to execute state machine"
  name                = "er-pluralsight-execute-hello-world-state-machine-${terraform.workspace}"
  schedule_expression = "rate(1 minute)"
}	

# Attach CloudWatch Events rule to State Machine and events rule role.
resource "aws_cloudwatch_event_target" "event_target" {
  rule     = aws_cloudwatch_event_rule.event_rule.id
  arn      = aws_sfn_state_machine.hello_world_state_machine.id
  role_arn = aws_iam_role.role_for_events_rule.arn
}
