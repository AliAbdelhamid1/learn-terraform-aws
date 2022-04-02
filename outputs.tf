output "client_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.consul-client.*.public_ip
}
output "server_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.consul-server.*.public_ip
}

