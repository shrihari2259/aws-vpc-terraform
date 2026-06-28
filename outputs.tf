output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 web server"
  value       = aws_instance.web.public_ip
}

output "ec2_instance_id" {
  description = "Instance ID of the EC2 web server"
  value       = aws_instance.web.id
}

output "s3_website_endpoint" {
  description = "S3 static website endpoint"
  value       = aws_s3_bucket_website_configuration.static_site.website_endpoint
}

output "s3_bucket_name" {
  description = "Name of the S3 static site bucket"
  value       = aws_s3_bucket.static_site.bucket
}

output "nat_gateway_ip" {
  description = "Public IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}
