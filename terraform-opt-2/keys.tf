resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "tf_ec2_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "local_sensitive_file" "private_key" {
  filename        = "private_key.pem"
  content         = tls_private_key.rsa.private_key_pem
  file_permission = "0600"
}
