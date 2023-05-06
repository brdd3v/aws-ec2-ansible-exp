resource "aws_ssm_association" "ssm_association" {
  name             = "AWS-RunAnsiblePlaybook"
  association_name = "AnsiblePlaybook"

  parameters = {
    playbookurl = "s3://${aws_s3_bucket.ansible_bucket.bucket}/${aws_s3_object.ansible_playbook.key}"
  }

  targets {
    key    = "InstanceIds"
    values = [aws_instance.ec2_instance.id]
  }

  output_location {
    s3_bucket_name = aws_s3_bucket.ansible_bucket.bucket
    s3_key_prefix  = "output"
  }
}
