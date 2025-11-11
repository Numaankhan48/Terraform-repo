provider "aws" {
  region = "us-west-2"
}

#########################
# VPC
#########################
resource "aws_vpc" "myvpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "MyVPC"
  }
}

#########################
# Subnet
#########################
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-west-2a" # Must match provider region
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet"
  }
}

#########################
# Internet Gateway
#########################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

#########################
# Route Table
#########################
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

#########################
# Associate Route Table
#########################
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}

#########################
# Security Group
#########################
resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebSG"
  }
}

#########################
# EC2 Instance
#########################
resource "aws_instance" "server" {
  ami                         = "ami-00f46ccd1cbfb363e" # Ubuntu AMI in us-west-2
  instance_type               = "t2.micro"
  key_name                    = "numaank" # Existing AWS key pair
  subnet_id                   = aws_subnet.sub1.id
  vpc_security_group_ids      = [aws_security_group.webSg.id]
  associate_public_ip_address = true

  tags = {
    Name = "UbuntuServer"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("C:/Users/dell/Downloads/numaank.pem") # Local PEM path
    host        = self.public_ip
    timeout     = "2m"
  }

  #########################
  # File provisioner: copy local file to EC2
  #########################
  provisioner "file" {
    source      = "file10"
    destination = "/home/ubuntu/file10"
  }

  #########################
  # Remote-exec provisioner: run commands on EC2
  #########################
  provisioner "remote-exec" {
    inline = [
      "sleep 30", # wait for instance to be fully ready
      "touch /home/ubuntu/file200",
      "echo 'hello from awsss' >> /home/ubuntu/file200"
    ]
  }

  #########################
  # Local-exec provisioner: run command locally
  #########################
  provisioner "local-exec" {
    command = "touch file500"
  }
}

#########################
# Optional: null_resource to re-run remote commands
#########################
# resource "null_resource" "run_script" {
#   provisioner "remote-exec" {
#     connection {
#       host        = aws_instance.server.public_ip
#       user        = "ubuntu"
#       private_key = file("C:/Users/dell/Downloads/numaank.pem")
#     }

#     inline = [
#       "echo 'hello again from awsdevops' >> /home/ubuntu/file200"
#     ]
#   }

#   triggers = {
#     always_run = timestamp() # Forces rerun every time
#   }
# }

# Notes:
# 1. Use `terraform taint aws_instance.server` if you want to rerun provisioners.
# 2. Ensure the Ubuntu AMI exists in us-west-2.
# 3. Ensure the key pair "numaank" exists in us-west-2 and matches your .pem file.
