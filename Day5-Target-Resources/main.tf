
resource "aws_instance" "name" {
    ami = "ami-0bdd88bd06d16ba03"
    instance_type = "t2.nano"
    availability_zone = "us-east-1a"
    tags = {
        Name = "ops"
    }

}

resource "aws_s3_bucket" "name" {
    bucket = "nkbucketttttt"
  

}


#target resource can be used to apply specific resource level only belwo command is the reference 
#terraform apply -target=aws_s3_bucket.name

#try skip resource 