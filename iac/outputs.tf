output "aws_vpc_id" {
  value = aws_vpc.default.id
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "default_sg_group_id" {
  value = aws_default_security_group.default_sg.id
}

output "custom_sg_group_id" {
  value = aws_security_group.custom_sg.id
}
