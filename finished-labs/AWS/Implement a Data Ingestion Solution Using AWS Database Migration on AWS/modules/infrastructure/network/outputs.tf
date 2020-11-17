output "vpc" {
  value = aws_vpc.vpc.id
}

output "total_subnets" {
  value = local.total_subnets
}

output "db_subnet_group" {
  value = aws_db_subnet_group.db_subnets.name
}

output "db_port" {
  value = var.db_port
}

output "project_name" {
  value = var.project_name
}

output "environment" {
  value = var.environment
}

output "public_subnets" {
  value = aws_subnet.public.*.id
}

output "private_subnets" {
  value = aws_subnet.private.*.id
}

output "db_subnets" {
  value = aws_subnet.db.*.id
}

