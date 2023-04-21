output "public_ip" {
  value = aws_instance.ec2_instance.public_ip
}

output "ssm_association_id" {
  value = aws_ssm_association.ssm_association.association_id
}
