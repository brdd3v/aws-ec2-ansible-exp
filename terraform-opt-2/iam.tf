resource "aws_iam_instance_profile" "instance_profile" {
  name = "iam_instance_profile"
  role = aws_iam_role.ec2_role_ssm.name
}

resource "aws_iam_role" "ec2_role_ssm" {
  name = "ec2_role_ssm"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    }
  )
}

resource "aws_iam_policy" "ec2_ssm_s3" {
  name = "ec2_ssm_s3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = "${aws_s3_bucket.ansible_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_s3" {
  role       = aws_iam_role.ec2_role_ssm.name
  policy_arn = aws_iam_policy.ec2_ssm_s3.arn
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_role_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
