
provider "aws" {
  region = "eu-central-1" # Change this to your desired region
}

# Define a variable for the number of instances
variable "instance_count" {
  default = 1
}

# Define a variable for the instance type
variable "instance_type" {
  default = "t2.micro"
}

# Define a variable for the AMI ID
variable "ami_id" {
  default = "ami-0be3bc68751c2dcf4" # Change this to your desired AMI
}

# Create a security group that allows SSH and HTTP access
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 instances
resource "aws_instance" "cub_task" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  security_groups = [aws_security_group.allow_ssh_http.name]
  user_data = <<EOF
#!/bin/bash
curl -sfL https://get.k3s.io | sh -
EOF

  tags = {
    Name = "cub_task-instance-${count.index + 1}"
  }
}

output "instance_public_ips" {
  value = [for instance in aws_instance.cub_task : instance.public_ip]
}
