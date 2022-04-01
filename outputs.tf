output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.consul.*.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.consul.*.public_ip
}
