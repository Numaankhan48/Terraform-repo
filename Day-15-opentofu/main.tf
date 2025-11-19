resource "aws_instance" "name" {
    ami = var.ami_id
    instance_type = var.type
    availability_zone = "us-east-1a"
    tags = {
      Name = "nkk"
    }
   
  
}