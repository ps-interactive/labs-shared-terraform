provider "aws" {
  profile    = "default"
  region     = "us-west-2"
}

# Create User
resource "aws_iam_user" "Alice" {
    name = "Alice.Acme"
    path = "/"
}


# Create Login with password encrypted with given pgp key
resource "aws_iam_user_login_profile" "alice_login" {
  user = "Alice.Acme"
  password_reset_required = false
  pgp_key = <<EOF
mQENBF7/ZBIBCACaiPgbzH2ATdoCIvJM3yaBp9InRPV3B+tOM9T4CG8d4ix701boZxm3D3wgHm1W4/N4TKvsDS2VvBslo3LPQ5TgFLbp7SDJonQDjAGIUt6MCoH6jOkn8Gsavm5YtC1TjR6jAJyEulclovhG58gY16e+ia85qPuOGSt7rxddcRQIUjtxbqhlJuReDNa1JvbHDRPqCbOQQz3E0guQIzpWWKm5uqMSHL/58FodysSOrb60QVXdA7lW+bt5dv7XUn5LNHSDKr4fiM5zwaTTfad9w2jxoxsHdRjEmvaq+rjmqbYv4Oh3Uz3VxYdtf0YTvTj8hqD7ssEmdEA9uEsA6SBLa8aRABEBAAG0SFBsdXJhbFNpZ2h0IExlYXJuZXIgKFBsdXJhbFNpZ2h0IExlYXJuaW5nIEdQRyBLZXkpIDxsZWFybmVyQGV4YW1wbGUuY29tPokBTgQTAQgAOBYhBMIaJceUc2za85t3l61FPuUnkQgTBQJe/2QSAhsDBQsJCAcCBhUKCQgLAgQWAgMBAh4BAheAAAoJEK1FPuUnkQgTxKIH/2oi+YwL89+/hOpRywQEp+Rx2K9LfysVSmnMIHoxlr6NYVxrfpupaH0SQOPIpdnk7vB65t9ybCsn8TWE4SHQdyN1f+CCwKRUhNa884E9ZfkfJcu1L7unkRMgbyZpy0+/r1oULsRqZhhrp1uY+EiXjvyb4+231fTCvFrcOwNIB2jTue6b1Uo0ToNhRvpVGajd8HJGVNSvuukhXyFcdkvwQsXmMjc78vX9tBEypRmgLADpFKqk4n6RxfZjxzNmWpLAqALZp8Hj+b4D2klc/X5a9EnrS5KvlWay4GO93U2G7pZgPc+l0gXVzCy+XM+Cdznbf5zR7QuT1hWayLlCuz6TTHq5AQ0EXv9kEgEIALlLZfFYjmLybCcrB0z0+N14zeT8s4qzOc2MPj2QVNvPVeolSIOzP/dEwa+4okYRJ+ODVCPhfIJxWsqJmWS7JSITcJXvNlL1TFNc2boay9QNTyaRgkPSubdkRpTpr6ZWswIwr1ZnE8qF/BoWs7dTs+0U+bSS7Fir7Me4s5wgxCzMiP57KCXn6VYrs/fGeIcxq04x0dGfO3EVc02D5vrSMqTRdROdnfrkWcM7AZdqEdPAYKPpFfsF9S6DIm64sSmJmLxSTWVaj+q6Y7Fth8aIkJ5V+dWNLrrWLwm/h2c4DmHomCBPK8+tAg4c/eCbzrnMObVMH5tbDNFRHEqgcNT5lCUAEQEAAYkBNgQYAQgAIBYhBMIaJceUc2za85t3l61FPuUnkQgTBQJe/2QSAhsMAAoJEK1FPuUnkQgTcAcH/0rMZ9eZID/sX0g2RhdGTl/nAeK80Yyxu4ofIQHz+cxh/K/lw+ZmlNepq4zK+ioADc41D1/CR91v4YInO1GqZr+plLun55rjiD/oUn7TMR2e5HEJp0/uTZxxFhaDQb86xXBxDblefzBBvfk199kXHKq2IyuamYUQjo9RfJkyDdXrMXPgunC4PCen5trD5taT9e9Hp7gZJuY1LQ5R+6/AVmHHjC980A6zhMJ5c3OP9ddck9M1A6M9O/xoxgH02C/drd/KF7diNcvmjnspfywdg17QDlJIb/cY5FXPaZkxAekmlcUMOCmt6NBNqOHps6IOQFcqwUnj52r3I/+0SSdfPas=
EOF
  password_length = 10
  depends_on = [aws_iam_user.Alice]
}


# Create user
resource "aws_iam_user" "Sarah" {
    name = "Sarah.Sign"
    path = "/"
}

# Create Login with password encrypted with given pgp key
resource "aws_iam_user_login_profile" "sarah_login" {
  user = "Sarah.Sign"
  password_reset_required = false
  pgp_key = <<EOF
mQENBF7/ZBIBCACaiPgbzH2ATdoCIvJM3yaBp9InRPV3B+tOM9T4CG8d4ix701boZxm3D3wgHm1W4/N4TKvsDS2VvBslo3LPQ5TgFLbp7SDJonQDjAGIUt6MCoH6jOkn8Gsavm5YtC1TjR6jAJyEulclovhG58gY16e+ia85qPuOGSt7rxddcRQIUjtxbqhlJuReDNa1JvbHDRPqCbOQQz3E0guQIzpWWKm5uqMSHL/58FodysSOrb60QVXdA7lW+bt5dv7XUn5LNHSDKr4fiM5zwaTTfad9w2jxoxsHdRjEmvaq+rjmqbYv4Oh3Uz3VxYdtf0YTvTj8hqD7ssEmdEA9uEsA6SBLa8aRABEBAAG0SFBsdXJhbFNpZ2h0IExlYXJuZXIgKFBsdXJhbFNpZ2h0IExlYXJuaW5nIEdQRyBLZXkpIDxsZWFybmVyQGV4YW1wbGUuY29tPokBTgQTAQgAOBYhBMIaJceUc2za85t3l61FPuUnkQgTBQJe/2QSAhsDBQsJCAcCBhUKCQgLAgQWAgMBAh4BAheAAAoJEK1FPuUnkQgTxKIH/2oi+YwL89+/hOpRywQEp+Rx2K9LfysVSmnMIHoxlr6NYVxrfpupaH0SQOPIpdnk7vB65t9ybCsn8TWE4SHQdyN1f+CCwKRUhNa884E9ZfkfJcu1L7unkRMgbyZpy0+/r1oULsRqZhhrp1uY+EiXjvyb4+231fTCvFrcOwNIB2jTue6b1Uo0ToNhRvpVGajd8HJGVNSvuukhXyFcdkvwQsXmMjc78vX9tBEypRmgLADpFKqk4n6RxfZjxzNmWpLAqALZp8Hj+b4D2klc/X5a9EnrS5KvlWay4GO93U2G7pZgPc+l0gXVzCy+XM+Cdznbf5zR7QuT1hWayLlCuz6TTHq5AQ0EXv9kEgEIALlLZfFYjmLybCcrB0z0+N14zeT8s4qzOc2MPj2QVNvPVeolSIOzP/dEwa+4okYRJ+ODVCPhfIJxWsqJmWS7JSITcJXvNlL1TFNc2boay9QNTyaRgkPSubdkRpTpr6ZWswIwr1ZnE8qF/BoWs7dTs+0U+bSS7Fir7Me4s5wgxCzMiP57KCXn6VYrs/fGeIcxq04x0dGfO3EVc02D5vrSMqTRdROdnfrkWcM7AZdqEdPAYKPpFfsF9S6DIm64sSmJmLxSTWVaj+q6Y7Fth8aIkJ5V+dWNLrrWLwm/h2c4DmHomCBPK8+tAg4c/eCbzrnMObVMH5tbDNFRHEqgcNT5lCUAEQEAAYkBNgQYAQgAIBYhBMIaJceUc2za85t3l61FPuUnkQgTBQJe/2QSAhsMAAoJEK1FPuUnkQgTcAcH/0rMZ9eZID/sX0g2RhdGTl/nAeK80Yyxu4ofIQHz+cxh/K/lw+ZmlNepq4zK+ioADc41D1/CR91v4YInO1GqZr+plLun55rjiD/oUn7TMR2e5HEJp0/uTZxxFhaDQb86xXBxDblefzBBvfk199kXHKq2IyuamYUQjo9RfJkyDdXrMXPgunC4PCen5trD5taT9e9Hp7gZJuY1LQ5R+6/AVmHHjC980A6zhMJ5c3OP9ddck9M1A6M9O/xoxgH02C/drd/KF7diNcvmjnspfywdg17QDlJIb/cY5FXPaZkxAekmlcUMOCmt6NBNqOHps6IOQFcqwUnj52r3I/+0SSdfPas=
EOF
  password_length = 10
  depends_on = [aws_iam_user.Sarah]
}

# Create user
resource "aws_iam_user" "Max" {
    name = "Max.Tech"
    path = "/"
}

# Create Login with password encrypted with given pgp key
resource "aws_iam_user_login_profile" "max_login" {
  user = "Max.Tech"
  password_reset_required = false
  pgp_key = <<EOF
mQENBF7/ZBIBCACaiPgbzH2ATdoCIvJM3yaBp9InRPV3B+tOM9T4CG8d4ix701boZxm3D3wgHm1W4/N4TKvsDS2VvBslo3LPQ5TgFLbp7SDJonQDjAGIUt6MCoH6jOkn8Gsavm5YtC1TjR6jAJyEulclovhG58gY16e+ia85qPuOGSt7rxddcRQIUjtxbqhlJuReDNa1JvbHDRPqCbOQQz3E0guQIzpWWKm5uqMSHL/58FodysSOrb60QVXdA7lW+bt5dv7XUn5LNHSDKr4fiM5zwaTTfad9w2jxoxsHdRjEmvaq+rjmqbYv4Oh3Uz3VxYdtf0YTvTj8hqD7ssEmdEA9uEsA6SBLa8aRABEBAAG0SFBsdXJhbFNpZ2h0IExlYXJuZXIgKFBsdXJhbFNpZ2h0IExlYXJuaW5nIEdQRyBLZXkpIDxsZWFybmVyQGV4YW1wbGUuY29tPokBTgQTAQgAOBYhBMIaJceUc2za85t3l61FPuUnkQgTBQJe/2QSAhsDBQsJCAcCBhUKCQgLAgQWAgMBAh4BAheAAAoJEK1FPuUnkQgTxKIH/2oi+YwL89+/hOpRywQEp+Rx2K9LfysVSmnMIHoxlr6NYVxrfpupaH0SQOPIpdnk7vB65t9ybCsn8TWE4SHQdyN1f+CCwKRUhNa884E9ZfkfJcu1L7unkRMgbyZpy0+/r1oULsRqZhhrp1uY+EiXjvyb4+231fTCvFrcOwNIB2jTue6b1Uo0ToNhRvpVGajd8HJGVNSvuukhXyFcdkvwQsXmMjc78vX9tBEypRmgLADpFKqk4n6RxfZjxzNmWpLAqALZp8Hj+b4D2klc/X5a9EnrS5KvlWay4GO93U2G7pZgPc+l0gXVzCy+XM+Cdznbf5zR7QuT1hWayLlCuz6TTHq5AQ0EXv9kEgEIALlLZfFYjmLybCcrB0z0+N14zeT8s4qzOc2MPj2QVNvPVeolSIOzP/dEwa+4okYRJ+ODVCPhfIJxWsqJmWS7JSITcJXvNlL1TFNc2boay9QNTyaRgkPSubdkRpTpr6ZWswIwr1ZnE8qF/BoWs7dTs+0U+bSS7Fir7Me4s5wgxCzMiP57KCXn6VYrs/fGeIcxq04x0dGfO3EVc02D5vrSMqTRdROdnfrkWcM7AZdqEdPAYKPpFfsF9S6DIm64sSmJmLxSTWVaj+q6Y7Fth8aIkJ5V+dWNLrrWLwm/h2c4DmHomCBPK8+tAg4c/eCbzrnMObVMH5tbDNFRHEqgcNT5lCUAEQEAAYkBNgQYAQgAIBYhBMIaJceUc2za85t3l61FPuUnkQgTBQJe/2QSAhsMAAoJEK1FPuUnkQgTcAcH/0rMZ9eZID/sX0g2RhdGTl/nAeK80Yyxu4ofIQHz+cxh/K/lw+ZmlNepq4zK+ioADc41D1/CR91v4YInO1GqZr+plLun55rjiD/oUn7TMR2e5HEJp0/uTZxxFhaDQb86xXBxDblefzBBvfk199kXHKq2IyuamYUQjo9RfJkyDdXrMXPgunC4PCen5trD5taT9e9Hp7gZJuY1LQ5R+6/AVmHHjC980A6zhMJ5c3OP9ddck9M1A6M9O/xoxgH02C/drd/KF7diNcvmjnspfywdg17QDlJIb/cY5FXPaZkxAekmlcUMOCmt6NBNqOHps6IOQFcqwUnj52r3I/+0SSdfPas=
EOF
  password_length = 10
  depends_on = [aws_iam_user.Max]
}

variable "subnet_id" {
    type = string
    default = ""
}
# [END]

# [START] AMI definitions
data "aws_ami" "amazon-linux-2" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = ["amzn2-ami-hvm*"]
    }
}
# [END]


# [START] IAM role and instance role profile for SSM
data "aws_iam_policy_document" "assume-role-policy-ec2" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "PluralsightRoleEC2InstanceBaseline" {
  name = "PluralsightRoleEC2InstanceBaseline"
  assume_role_policy = data.aws_iam_policy_document.assume-role-policy-ec2.json
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "S3Access" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "PluralsightRoleEC2InstanceBaseline-AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.PluralsightRoleEC2InstanceBaseline.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

resource "aws_iam_role_policy_attachment" "PluralsightRoleEC2InstanceBaseline-S3" {
  role       = aws_iam_role.PluralsightRoleEC2InstanceBaseline.name
  policy_arn = data.aws_iam_policy.S3Access.arn
}

resource "aws_iam_instance_profile" "PluralsightRoleEC2InstanceBaseline" {
  name  = "PluralsightRoleEC2InstanceBaseline"
  role = aws_iam_role.PluralsightRoleEC2InstanceBaseline.name
}
# [END]


# Create random id
resource "random_uuid" "uuid" {

}

# Create bucket
resource "aws_s3_bucket" "password_bucket" {
  bucket = "password-${random_uuid.uuid.result}"
  acl    = "private"
}

# Create separate files as objects in S3 bucket
resource "aws_s3_bucket_object" "key_file" {
  bucket = aws_s3_bucket.password_bucket.id
  key = "learner-private.key"
  source = "src/learner-private.key"
}

resource "tls_private_key" "pki" {
  algorithm   = "RSA"
  rsa_bits = "4096"
}

resource "aws_key_pair" "terrakey" {
  key_name   = "lab-key"
  public_key = "${tls_private_key.pki.public_key_openssh}"
}

resource "aws_instance" "Prod-Web-Instance-1" {
    ami                          = data.aws_ami.amazon-linux-2.id
    instance_type                = "t2.micro"
    subnet_id                    = var.subnet_id
    iam_instance_profile         = aws_iam_instance_profile.PluralsightRoleEC2InstanceBaseline.name
    disable_api_termination      = false
    ebs_optimized                = false
    key_name                     = aws_key_pair.terrakey.key_name
    user_data = <<EOF
        #! /bin/bash
        aws s3 cp s3://${aws_s3_bucket.password_bucket.bucket}/learner-private.key .
        aws s3 rm s3://${aws_s3_bucket.password_bucket.bucket}/learner-private.key
        gpg --import learner-private.key && echo ${aws_iam_user_login_profile.alice_login.encrypted_password} | base64 -d | gpg -d -o password_alice.txt
        sed -i '1s/^/Alice.Acme\n/' password_alice.txt
        aws s3 cp password_alice.txt s3://${aws_s3_bucket.password_bucket.bucket}/
        echo ${aws_iam_user_login_profile.sarah_login.encrypted_password} | base64 -d | gpg -d -o password_sarah.txt
        sed -i '1s/^/Sarah.Sign\n/' password_sarah.txt
        aws s3 cp password_sarah.txt s3://${aws_s3_bucket.password_bucket.bucket}/
        echo ${aws_iam_user_login_profile.max_login.encrypted_password} | base64 -d | gpg -d -o password_max.txt
        sed -i '1s/^/Max.Tech\n/' password_max.txt
        aws s3 cp password_max.txt s3://${aws_s3_bucket.password_bucket.bucket}/
    EOF
    depends_on = [aws_s3_bucket.password_bucket]

    tags = {
      Name = "Prod-Web-Instance-1"
    }
}

# Create Groups
resource "aws_iam_group" "my_finance" {
  name = "finance"
}

resource "aws_iam_group" "my_developers" {
  name = "developers"
}

resource "aws_iam_group" "my_admin" {
  name = "administrators"
}

# Add Users to Groups
resource "aws_iam_group_membership" "my_admin" {
    name  = "admin-group-membership"
    group = "administrators"
    users = [
      aws_iam_user.Alice.name
    ]
}

resource "aws_iam_group_membership" "my_finance" {
    name  = "finance-group-membership"
    group = "finance"
    users = [
      aws_iam_user.Max.name
    ]
}

resource "aws_iam_group_membership" "my_developers" {
    name  = "dev-group-membership"
    group = "developers"
    users = [
      aws_iam_user.Sarah.name
    ]
}

# Create Group Policies
resource "aws_iam_policy" "my_developer_policy" {
    name   = "my_developer_policy"
    # group  = "developers"
    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "ec2:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "my_finance_policy" {
    name   = "my_finance_policy"
    # group  = "finance"
    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "kms:CreateAlias",
            "kms:CreateKey",
            "kms:DeleteAlias",
            "kms:Describe*",
            "kms:GenerateRandom",
            "kms:Get*",
            "kms:List*",
            "kms:TagResource",
            "kms:UntagResource",
            "iam:ListGroups",
            "iam:ListRoles",
            "iam:ListUsers"
        ],
        "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "my_admin_policy" {
    name   = "my_admin_policy"
    # group  = "administrators"
    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
POLICY
}

# Attach policies to groups
resource "aws_iam_group_policy_attachment" "admin-policy-attach" {
  group      = aws_iam_group.my_admin.name
  policy_arn = aws_iam_policy.my_admin_policy.arn
}
resource "aws_iam_group_policy_attachment" "finance-policy-attach" {
  group      = aws_iam_group.my_developers.name
  policy_arn = aws_iam_policy.my_developer_policy.arn
}
resource "aws_iam_group_policy_attachment" "developer-policy-attach" {
  group      = aws_iam_group.my_finance.name
  policy_arn = aws_iam_policy.my_finance_policy.arn
}

# output "alicepassword" {
#   value = aws_iam_user_login_profile.alice_login.encrypted_password
# }
# output "sarahpassword" {
#   value = aws_iam_user_login_profile.sarah_login.encrypted_password
# }
# output "maxpassword" {
#   value = aws_iam_user_login_profile.max_login.encrypted_password
# }
