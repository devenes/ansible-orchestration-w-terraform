provider "aws" {
  region = "us-east-2" # Define the region where the resource will be created
}

variable "vpc_id" {
  type    = string
  default = "vpc-02ca20d6c9bae6b3c" # Define your VPC ID
}

variable "instance_type" {
  type    = string
  default = "t2.micro" # Define your instance type
}

data "aws_ami" "ubuntu" {
  most_recent = true # Find the most recent AMI

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"] # Find the AMI with the correct name
  }
  filter {
    name   = "virtualization-type" # Find the AMI with the correct virtualization type
    values = ["hvm"]
  }
  owners = ["099720109477"] # Find the AMI with the correct owner
}

resource "aws_security_group" "application_server_sg" { # Create a security group
  name        = "application_server_sg"                 # Define the name of the security group
  description = "Application Server SG"                 # Define the description of the security group
  vpc_id      = var.vpc_id                              # Define the VPC ID

  ingress {
    from_port   = 22            # Define the port number for the ingress rule
    to_port     = 80            # Define the port number for the ingress rule
    protocol    = "tcp"         # Define the protocol for the ingress rule
    cidr_blocks = ["0.0.0.0/0"] # Define the CIDR block for the ingress rule
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"] # Allow all traffic
    ipv6_cidr_blocks = ["::/0"]      # Allow all IPv6 traffic
  }

}
resource "aws_instance" "application_servers" {

  count                  = 2                                             # Define the number of instances you want to create
  ami                    = data.aws_ami.ubuntu.id                        # Define the AMI ID
  instance_type          = var.instance_type                             # Define the instance type
  key_name               = "ssh1"                                        # Define your existing key pair name
  vpc_security_group_ids = [aws_security_group.application_server_sg.id] # Define the security group ID
  depends_on             = [aws_security_group.application_server_sg]    # Wait for the security group to be created before creating the instance

  tags = {
    Name = "AppServer-${count.index + 1}"
  }
}

output "public_ip_1" {
  value = aws_instance.application_servers[0].public_ip # Define the output value
}

output "public_ip_2" {
  value = aws_instance.application_servers[1].public_ip # Define the output value
}
