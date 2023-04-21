resource "aws_instance" "ec2_instance" {
  ami                         = "ami-0d497a49e7d359666" # Ubuntu, 20.04 LTS
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.pub_subnet.id
  security_groups             = [aws_security_group.sg.id]
  key_name                    = aws_key_pair.key_pair.key_name
  associate_public_ip_address = true

  tags = {
    Name = "ec2_instance"
  }

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./${local_sensitive_file.private_key.filename}")
      host        = self.public_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${self.public_ip}, --private-key ${local_sensitive_file.private_key.filename} nginx.yaml"
  }
}
