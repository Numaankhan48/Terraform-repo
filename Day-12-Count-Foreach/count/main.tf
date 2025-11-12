resource "aws_instance" "name" {
    ami = "ami-07860a2d7eb515d9a"
    instance_type = "t2.micro"
    count = 2
    # tags = {
    #   Name = "dev"
    # }
  tags = {
      Name = "nk-${count.index}"
    }
}