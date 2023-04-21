resource "aws_s3_bucket" "ansible_bucket" {
  bucket        = "aws-ec2-ansible-exp-bucket"
  force_destroy = true
}

resource "aws_s3_object" "ansible_playbook" {
  key    = "nginx.yaml"
  bucket = aws_s3_bucket.ansible_bucket.id
  source = "nginx.yaml"
}
