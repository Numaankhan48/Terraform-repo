variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  description = "Amazon Linux AMI"
  default     = "ami-06b21ccaeff8cd686" # us-east-1 Amazon Linux 2
}
