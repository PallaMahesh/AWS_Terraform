output "instance_id" {
  value = aws_instance.react_flask_app.id
}

output "public" {
  value = aws_instance.react_flask_app.public_ip
}