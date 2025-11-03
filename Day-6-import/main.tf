resource "aws_instance" "name" {
  ami = "ami-0bdd88bd06d16ba03"
  instance_type = "t3.micro"
  tags = {
    Name = "nkserver"
  }

}

#example command terraform import aws_instance.name i-0f17233b6248bc93a