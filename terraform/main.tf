# Provider Configuration
# Specifies which cloud provider to use and in which region
provider "aws" {
  region = "us-west-1"
  profile = "default"
}

# # EC2 Instance Resource
# # Creates a single EC2 instance in AWS
# resource "aws_instance" "vm01" {

#   # AMI (Amazon Machine Image) - Amazon Linux 2023 for us-east-1
#   ami = "ami-0e2de80e7636c4837"
#   # Challenge: use latest LTS AMI id from Amazon using data sources (data-ami.tf)
#   # ami = data.aws_ami.amazon_linux_2023.id

#   instance_type = "t3.micro"

#   tags = {
#     Name = "Vishwa"
#   }
# }

# Latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_security_group" "vm_sg" {
  name        = "gha-vm-sg"
  description = "Allow SSH and 8080"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # tighten later if you can
  }

  ingress {
    description = "App Port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vm" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = "key1-nc"
  vpc_security_group_ids = [aws_security_group.vm_sg.id]

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "gha-docker-vm"
  }
}