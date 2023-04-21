resource "aws_instance" "ec2_instance" {
  ami                         = "ami-0d497a49e7d359666" # Ubuntu, 20.04 LTS
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.pub_subnet.id
  security_groups             = [aws_security_group.sg.id]
  key_name                    = aws_key_pair.key_pair.key_name
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name
  associate_public_ip_address = true
  user_data                   = file("ec2_user_data.sh")

  tags = {
    Name = "ec2_instance"
  }
}
