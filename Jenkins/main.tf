resource "aws_instance" "jenkins_test" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "jenkins-terraform-test"
  }
}

output "instance_public_ip" {
  value = aws_instance.jenkins_test.public_ip
}
