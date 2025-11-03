resource "aws_vpc" "name1" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "nk_vpc"
    }
  
}


resource "aws_subnet" "name2" {
    vpc_id = aws_vpc.name.id
    cidr_block = "10.0.0.0/24"
    tags = {
      Name = "nk_subnet"
    }
  
}