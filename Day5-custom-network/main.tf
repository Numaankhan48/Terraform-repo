# Create VPC
resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "custom-vpc"
    }
  
}
# Create subnets
resource "aws_subnet" "name" {
    vpc_id = aws_vpc.name.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    tags = {
      Name = "custom-subnet-1-public"
    }
  
}

resource "aws_subnet" "name-2" {
    vpc_id = aws_vpc.name.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1b"
    tags = {
      Name = "custom-subnet-2-private"
    }
  
}
# Create IGW and attach to VPC

resource "aws_internet_gateway" "name" {
    vpc_id = aws_vpc.name.id
  
}
# Create Route table and edit routes

resource "aws_route_table" "name" {
    vpc_id = aws_vpc.name.id

   route {

    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.name.id

   }
}
# Create subnet association

resource "aws_route_table_association" "name" {
    subnet_id = aws_subnet.name.id
    route_table_id = aws_route_table.name.id
  
}
# Create SG
resource "aws_security_group" "dev_sg" {
  name   = "allow_tls"
  vpc_id = aws_vpc.name.id
  tags = {
    Name = "dev-sg"
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
  

# Create servers  

resource "aws_instance" "public" {
    ami = "ami-0bdd88bd06d16ba03"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.name.id
    vpc_security_group_ids = [ aws_security_group.dev_sg.id ]
    associate_public_ip_address = true
    tags = {
      Name = "public-ec2"
    }
  
}
resource "aws_instance" "pvt" {
    ami = "ami-0bdd88bd06d16ba03"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.name-2.id
    vpc_security_group_ids = [ aws_security_group.dev_sg.id ]
    
    tags = {
      Name = "private-ec2"
    }
}
    # Step 1: Create Elastic IP for NAT Gateway

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "nat-eip"
  }
}


# Step 2: Create NAT Gateway in Public Subnet

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.name.id

  tags = {
    Name = "nat-gateway"
  }

  depends_on = [aws_internet_gateway.name]
}


# Step 3: Create Private Route Table and Add NAT Route

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.name.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}


# Step 4: Associate Private Subnet with Private Route Table

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.name-2.id
  route_table_id = aws_route_table.private.id
}


