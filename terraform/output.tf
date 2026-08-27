output "instance_ip" {
  value = aws_instance.project_instance.public_ip
}