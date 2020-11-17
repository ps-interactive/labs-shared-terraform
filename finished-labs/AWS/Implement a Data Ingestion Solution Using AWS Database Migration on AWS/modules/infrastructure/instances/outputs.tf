output "bastion_id" {
  value = aws_instance.bastion.id
}

output "db_endpoint" {
  value = aws_db_instance.db.endpoint
}
