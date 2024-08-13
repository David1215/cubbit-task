
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
  default = "ami-00060fac2f8c42d30" # Change this to your desired AMI
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
curl -sfL https://get.k3s.io | sh -
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/k3s.yaml
chown ec2-user:ec2-user /home/ec2-user/.kubeconfig
EOF

  tags = {
    Name = "cub_task-instance-${count.index + 1}"
  }
}

resource "aws_ecr_repository" "go-app-registry" {
  name                 = "go-app"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
}

output "instance_public_ips" {
  value = [for instance in aws_instance.cub_task : instance.public_ip]
}
