resource "minio_s3_bucket" "kestra" {
  bucket = "kestra"
}

resource "minio_iam_user" "kestra" {
  name = "kestra"
}

resource "minio_iam_policy" "kestra" {
  name   = "kestra"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::kestra/*"
      ]
    }
  ]
}
EOF
  lifecycle {
    ignore_changes = [policy]
  }
}

resource "minio_iam_user_policy_attachment" "kestra" {
  user_name   = minio_iam_user.kestra.id
  policy_name = minio_iam_policy.kestra.id
}

resource "minio_iam_service_account" "kestra" {
  target_user = minio_iam_user.kestra.name
  lifecycle {
    ignore_changes = [policy]
  }
}

locals {
  minio = {
    endpoint   = local.minio["IMPLICIT_HOST"]
    endpoint   = local.minio["API_SERVICE_PORT"]
    region     = local.minio["REGION"]
    access_key = minio_iam_service_account.kestra.access_key
    secret_key = minio_iam_service_account.kestra.secret_key
    bucket     = minio_s3_bucket.kestra.bucket
  }
}
