/*
locals {
  my_email = split("/", data.aws_caller_identity.current.arn)[2]
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

 
data "aws_iam_policy" "demo_user_permissions_boundary" {
  name = "DemoUser"
}

resource "aws_iam_user" "boundary_user" {
  name                 = "demo-${local.my_email}-boundary"
  permissions_boundary = data.aws_iam_policy.demo_user_permissions_boundary.arn
  force_destroy        = true
}


resource "aws_iam_user_policy_attachment" "demo_permissions" {
  user       = aws_iam_user.boundary_user.name
  policy_arn = data.aws_iam_policy.demo_user_permissions_boundary.arn
} 


resource "aws_iam_user_policy_attachment" "session_storage" {
  user       = aws_iam_user.boundary_user.name
  policy_arn = aws_iam_policy.session_storage_policy.arn
}

resource "aws_s3_bucket_public_access_block" "session_storage" {
  bucket = aws_s3_bucket.session_storage.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
resource "aws_s3_bucket_acl" "session_storage" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.session_storage,
  ]

  bucket = aws_s3_bucket.session_storage.id
  acl    = "public-read"
} 
*/

resource "aws_iam_instance_profile" "worker_instance_profile" {
  name = "${var.deployment_id}-worker-profile"
  role = aws_iam_role.session_storage_role.name
}

resource "aws_s3_bucket" "session_storage" {
  bucket        = "${var.deployment_id}-session-storage-bucket"
  force_destroy = true
}

resource "aws_iam_policy" "session_storage_policy" {
  name        = "${var.deployment_id}-session-storage-policy"
  path        = "/"
  description = "Boundary session storage policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "S3Permissions",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectAttributes"
        ],
        "Resource" : [
          "${aws_s3_bucket.session_storage.arn}/*"
        ]
      },
      /*
      {
        "Sid" : "UserPermissions",
        "Effect" : "Allow",
        "Action" : [
          "iam:DeleteAccessKey",
          "iam:GetUser",
          "iam:CreateAccessKey"
        ],
        "Resource" : [
          "${aws_iam_user.boundary_user.arn}"
        ]
      },
      */
    ]
  })
}

resource "aws_iam_role" "session_storage_role" {
  name = "${var.deployment_id}-session-storage-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  inline_policy {
    name   = "${var.deployment_id}-session-storage-policy"
    policy = aws_iam_policy.session_storage_policy.policy
  }

  tags = {
    /* tag-key = "tag-value" */
  }
}

